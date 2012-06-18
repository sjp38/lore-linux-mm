Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id AF6D36B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 18:49:51 -0400 (EDT)
Received: by obbtb8 with SMTP id tb8so3428077obb.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 15:49:50 -0700 (PDT)
Message-ID: <1340059850.3416.3.camel@lappy>
Subject: Re: Early boot panic on machine with lots of memory
From: Sasha Levin <levinsasha928@gmail.com>
Date: Tue, 19 Jun 2012 00:50:50 +0200
In-Reply-To: <20120618223203.GE32733@google.com>
References: <1339623535.3321.4.camel@lappy>
	 <20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
	 <1339667440.3321.7.camel@lappy> <20120618223203.GE32733@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, 2012-06-18 at 15:32 -0700, Tejun Heo wrote:
> * Can you please post disassembly of the whole function?  It seems
>   like rsv->regions[] was corrupt.  I want to verify other registers
>   too.

Here it is, with the patch you've asked to be tested applied if it matters any:

0000000000000000 <__next_free_mem_range>:
 * in lockstep and returns each intersection.
 */
void __init_memblock __next_free_mem_range(u64 *idx, int nid,
					   phys_addr_t *out_start,
					   phys_addr_t *out_end, int *out_nid)
{
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	41 57                	push   %r15
   6:	41 56                	push   %r14
		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
			continue;

		/* scan areas before each reservation for intersection */
		for ( ; ri < rsv->cnt + 1; ri++) {
			struct memblock_region *r = &rsv->regions[ri];
   8:	45 31 f6             	xor    %r14d,%r14d
 * in lockstep and returns each intersection.
 */
void __init_memblock __next_free_mem_range(u64 *idx, int nid,
					   phys_addr_t *out_start,
					   phys_addr_t *out_end, int *out_nid)
{
   b:	41 55                	push   %r13
   d:	41 54                	push   %r12
   f:	53                   	push   %rbx
  10:	48 83 ec 38          	sub    $0x38,%rsp
  14:	48 89 55 b0          	mov    %rdx,-0x50(%rbp)
  18:	48 89 4d a8          	mov    %rcx,-0x58(%rbp)
  1c:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  20:	4c 89 45 a0          	mov    %r8,-0x60(%rbp)
	struct memblock_type *mem = &memblock.memory;
	struct memblock_type *rsv = &memblock.reserved;
	int mi = *idx & 0xffffffff;
	int ri = *idx >> 32;

	for ( ; mi < mem->cnt; mi++) {
  24:	48 8b 0d 00 00 00 00 	mov    0x0(%rip),%rcx        # 2b <__next_free_mem_range+0x2b>
			27: R_X86_64_PC32	memblock+0x4
					   phys_addr_t *out_start,
					   phys_addr_t *out_end, int *out_nid)
{
	struct memblock_type *mem = &memblock.memory;
	struct memblock_type *rsv = &memblock.reserved;
	int mi = *idx & 0xffffffff;
  2b:	48 8b 07             	mov    (%rdi),%rax
		/* only memory regions are associated with nodes, check it */
		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
			continue;

		/* scan areas before each reservation for intersection */
		for ( ; ri < rsv->cnt + 1; ri++) {
  2e:	4c 8b 1d 00 00 00 00 	mov    0x0(%rip),%r11        # 35 <__next_free_mem_range+0x35>
			31: R_X86_64_PC32	memblock+0x24
					   phys_addr_t *out_end, int *out_nid)
{
	struct memblock_type *mem = &memblock.memory;
	struct memblock_type *rsv = &memblock.reserved;
	int mi = *idx & 0xffffffff;
	int ri = *idx >> 32;
  35:	48 89 c2             	mov    %rax,%rdx
					   phys_addr_t *out_start,
					   phys_addr_t *out_end, int *out_nid)
{
	struct memblock_type *mem = &memblock.memory;
	struct memblock_type *rsv = &memblock.reserved;
	int mi = *idx & 0xffffffff;
  38:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
	int ri = *idx >> 32;
  3c:	48 c1 ea 20          	shr    $0x20,%rdx

	for ( ; mi < mem->cnt; mi++) {
		struct memblock_region *m = &mem->regions[mi];
  40:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 47 <__next_free_mem_range+0x47>
			43: R_X86_64_PC32	memblock+0x1c
	struct memblock_type *mem = &memblock.memory;
	struct memblock_type *rsv = &memblock.reserved;
	int mi = *idx & 0xffffffff;
	int ri = *idx >> 32;

	for ( ; mi < mem->cnt; mi++) {
  47:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
		struct memblock_region *m = &mem->regions[mi];
  4b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
		/* only memory regions are associated with nodes, check it */
		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
			continue;

		/* scan areas before each reservation for intersection */
		for ( ; ri < rsv->cnt + 1; ri++) {
  4f:	49 8d 5b 01          	lea    0x1(%r11),%rbx
			struct memblock_region *r = &rsv->regions[ri];
  53:	4c 8b 25 00 00 00 00 	mov    0x0(%rip),%r12        # 5a <__next_free_mem_range+0x5a>
			56: R_X86_64_PC32	memblock+0x3c
	struct memblock_type *mem = &memblock.memory;
	struct memblock_type *rsv = &memblock.reserved;
	int mi = *idx & 0xffffffff;
	int ri = *idx >> 32;

	for ( ; mi < mem->cnt; mi++) {
  5a:	e9 c8 00 00 00       	jmpq   127 <__next_free_mem_range+0x127>
		struct memblock_region *m = &mem->regions[mi];
  5f:	4d 6b ed 18          	imul   $0x18,%r13,%r13
  63:	4c 03 6d c0          	add    -0x40(%rbp),%r13
		phys_addr_t m_start = m->base;
  67:	4d 8b 4d 00          	mov    0x0(%r13),%r9
		phys_addr_t m_end = m->base + m->size;
  6b:	4d 89 ca             	mov    %r9,%r10
  6e:	4d 03 55 08          	add    0x8(%r13),%r10

		/* only memory regions are associated with nodes, check it */
		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
  72:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  78:	0f 84 9a 00 00 00    	je     118 <__next_free_mem_range+0x118>
	r->nid = nid;
}

static inline int memblock_get_region_node(const struct memblock_region *r)
{
	return r->nid;
  7e:	41 3b 75 10          	cmp    0x10(%r13),%esi
  82:	0f 85 9c 00 00 00    	jne    124 <__next_free_mem_range+0x124>
  88:	e9 8b 00 00 00       	jmpq   118 <__next_free_mem_range+0x118>
			continue;

		/* scan areas before each reservation for intersection */
		for ( ; ri < rsv->cnt + 1; ri++) {
			struct memblock_region *r = &rsv->regions[ri];
  8d:	4c 6b c0 18          	imul   $0x18,%rax,%r8
			phys_addr_t r_start = ri ? r[-1].base + r[-1].size : 0;
  91:	31 c9                	xor    %ecx,%ecx
		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
			continue;

		/* scan areas before each reservation for intersection */
		for ( ; ri < rsv->cnt + 1; ri++) {
			struct memblock_region *r = &rsv->regions[ri];
  93:	4f 8d 04 04          	lea    (%r12,%r8,1),%r8
			phys_addr_t r_start = ri ? r[-1].base + r[-1].size : 0;
  97:	85 d2                	test   %edx,%edx
  99:	74 08                	je     a3 <__next_free_mem_range+0xa3>
  9b:	49 8b 48 f0          	mov    -0x10(%r8),%rcx
  9f:	49 03 48 e8          	add    -0x18(%r8),%rcx
			phys_addr_t r_end = ri < rsv->cnt ? r->base : ULLONG_MAX;
  a3:	48 83 cf ff          	or     $0xffffffffffffffff,%rdi
  a7:	4c 39 d8             	cmp    %r11,%rax
  aa:	73 03                	jae    af <__next_free_mem_range+0xaf>
  ac:	49 8b 38             	mov    (%r8),%rdi

			/* if ri advanced past mi, break out to advance mi */
			if (r_start >= m_end)
  af:	4c 39 d1             	cmp    %r10,%rcx
  b2:	73 70                	jae    124 <__next_free_mem_range+0x124>
				break;
			/* if the two regions intersect, we're done */
			if (m_start < r_end) {
  b4:	4c 39 cf             	cmp    %r9,%rdi
  b7:	76 5d                	jbe    116 <__next_free_mem_range+0x116>
				if (out_start)
  b9:	48 83 7d b0 00       	cmpq   $0x0,-0x50(%rbp)
  be:	74 0e                	je     ce <__next_free_mem_range+0xce>
					*out_start = max(m_start, r_start);
  c0:	4c 39 c9             	cmp    %r9,%rcx
  c3:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  c7:	49 0f 42 c9          	cmovb  %r9,%rcx
  cb:	48 89 08             	mov    %rcx,(%rax)
				if (out_end)
  ce:	48 83 7d a8 00       	cmpq   $0x0,-0x58(%rbp)
  d3:	74 11                	je     e6 <__next_free_mem_range+0xe6>
					*out_end = min(m_end, r_end);
  d5:	4c 39 d7             	cmp    %r10,%rdi
  d8:	4c 89 d0             	mov    %r10,%rax
  db:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  df:	48 0f 46 c7          	cmovbe %rdi,%rax
  e3:	48 89 01             	mov    %rax,(%rcx)
				if (out_nid)
  e6:	48 83 7d a0 00       	cmpq   $0x0,-0x60(%rbp)
  eb:	74 0a                	je     f7 <__next_free_mem_range+0xf7>
					*out_nid = memblock_get_region_node(m);
  ed:	41 8b 45 10          	mov    0x10(%r13),%eax
  f1:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  f5:	89 01                	mov    %eax,(%rcx)
				/*
				 * The region which ends first is advanced
				 * for the next iteration.
				 */
				if (m_end <= r_end)
  f7:	4c 39 d7             	cmp    %r10,%rdi
  fa:	72 05                	jb     101 <__next_free_mem_range+0x101>
					mi++;
  fc:	41 ff c7             	inc    %r15d
  ff:	eb 02                	jmp    103 <__next_free_mem_range+0x103>
				else
					ri++;
 101:	ff c2                	inc    %edx
				*idx = (u32)mi | (u64)ri << 32;
 103:	48 c1 e2 20          	shl    $0x20,%rdx
 107:	45 89 ff             	mov    %r15d,%r15d
 10a:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
 10e:	4c 09 fa             	or     %r15,%rdx
 111:	48 89 10             	mov    %rdx,(%rax)
				return;
 114:	eb 30                	jmp    146 <__next_free_mem_range+0x146>
		/* only memory regions are associated with nodes, check it */
		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
			continue;

		/* scan areas before each reservation for intersection */
		for ( ; ri < rsv->cnt + 1; ri++) {
 116:	ff c2                	inc    %edx
 118:	48 63 c2             	movslq %edx,%rax
 11b:	48 39 d8             	cmp    %rbx,%rax
 11e:	0f 82 69 ff ff ff    	jb     8d <__next_free_mem_range+0x8d>
 124:	41 ff c6             	inc    %r14d
 127:	8b 4d d0             	mov    -0x30(%rbp),%ecx
 12a:	45 8d 3c 0e          	lea    (%r14,%rcx,1),%r15d
	struct memblock_type *mem = &memblock.memory;
	struct memblock_type *rsv = &memblock.reserved;
	int mi = *idx & 0xffffffff;
	int ri = *idx >> 32;

	for ( ; mi < mem->cnt; mi++) {
 12e:	4d 63 ef             	movslq %r15d,%r13
 131:	4c 3b 6d c8          	cmp    -0x38(%rbp),%r13
 135:	0f 82 24 ff ff ff    	jb     5f <__next_free_mem_range+0x5f>
			}
		}
	}

	/* signal end of iteration */
	*idx = ULLONG_MAX;
 13b:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
 13f:	48 c7 00 ff ff ff ff 	movq   $0xffffffffffffffff,(%rax)
}
 146:	48 83 c4 38          	add    $0x38,%rsp
 14a:	5b                   	pop    %rbx
 14b:	41 5c                	pop    %r12
 14d:	41 5d                	pop    %r13
 14f:	41 5e                	pop    %r14
 151:	41 5f                	pop    %r15
 153:	c9                   	leaveq 
 154:	c3                   	retq

> * Can you please try the following patch?
> 
>   https://lkml.org/lkml/2012/6/15/510

The patch didn't seem to help.

Since this is pretty easy to reproduce, let me know if adding any debug code will prove to be helpful in further analysis.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
