Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE3176B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 13:15:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so345953160pfg.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 10:15:27 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id zi9si3884825pac.192.2016.08.02.10.15.26
        for <linux-mm@kvack.org>;
        Tue, 02 Aug 2016 10:15:27 -0700 (PDT)
From: "Roberts, William C" <william.c.roberts@intel.com>
Subject: RE: [PATCH] [RFC] Introduce mmap randomization
Date: Tue, 2 Aug 2016 17:15:25 +0000
Message-ID: <476DC76E7D1DF2438D32BFADF679FC56012780D0@ORSMSX103.amr.corp.intel.com>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <20160726200309.GJ4541@io.lakedaemon.net>
 <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
 <20160726205944.GM4541@io.lakedaemon.net>
 <476DC76E7D1DF2438D32BFADF679FC5601260068@ORSMSX103.amr.corp.intel.com>
In-Reply-To: <476DC76E7D1DF2438D32BFADF679FC5601260068@ORSMSX103.amr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Roberts, William C" <william.c.roberts@intel.com>, Jason Cooper <jason@lakedaemon.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "nnk@google.com" <nnk@google.com>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>

<snip>
> >
> > No, I mean changes to mm/mmap.o.
>=20

>From UML build:

NEW:
0000000000001610 <unmapped_area>:
    1610:	55                   	push   %rbp
    1611:	48 89 e5             	mov    %rsp,%rbp
    1614:	41 54                	push   %r12
    1616:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
    161a:	53                   	push   %rbx
    161b:	48 89 fb             	mov    %rdi,%rbx
    161e:	48 83 ec 10          	sub    $0x10,%rsp
    1622:	48 25 00 e0 ff ff    	and    $0xffffffffffffe000,%rax
    1628:	48 8b 57 08          	mov    0x8(%rdi),%rdx
    162c:	48 03 57 20          	add    0x20(%rdi),%rdx
    1630:	48 8b 00             	mov    (%rax),%rax
    1633:	4c 8b 88 b0 01 00 00 	mov    0x1b0(%rax),%r9
    163a:	48 c7 c0 f4 ff ff ff 	mov    $0xfffffffffffffff4,%rax
    1641:	0f 82 05 01 00 00    	jb     174c <unmapped_area+0x13c>
    1647:	48 8b 7f 18          	mov    0x18(%rdi),%rdi
    164b:	48 39 d7             	cmp    %rdx,%rdi
    164e:	0f 82 f8 00 00 00    	jb     174c <unmapped_area+0x13c>
    1654:	4c 8b 63 10          	mov    0x10(%rbx),%r12
    1658:	48 29 d7             	sub    %rdx,%rdi
    165b:	49 39 fc             	cmp    %rdi,%r12
    165e:	0f 87 e8 00 00 00    	ja     174c <unmapped_area+0x13c>
    1664:	49 8b 41 08          	mov    0x8(%r9),%rax
    1668:	48 85 c0             	test   %rax,%rax
    166b:	0f 84 93 00 00 00    	je     1704 <unmapped_area+0xf4>
    1671:	49 8b 49 08          	mov    0x8(%r9),%rcx
    1675:	48 39 51 18          	cmp    %rdx,0x18(%rcx)
    1679:	0f 82 85 00 00 00    	jb     1704 <unmapped_area+0xf4>
    167f:	4e 8d 14 22          	lea    (%rdx,%r12,1),%r10
    1683:	48 83 e9 20          	sub    $0x20,%rcx
    1687:	48 8b 31             	mov    (%rcx),%rsi
    168a:	4c 39 d6             	cmp    %r10,%rsi
    168d:	72 15                	jb     16a4 <unmapped_area+0x94>
    168f:	48 8b 41 30          	mov    0x30(%rcx),%rax
    1693:	48 85 c0             	test   %rax,%rax
    1696:	74 0c                	je     16a4 <unmapped_area+0x94>
    1698:	48 39 50 18          	cmp    %rdx,0x18(%rax)
    169c:	72 06                	jb     16a4 <unmapped_area+0x94>
    169e:	48 8d 48 e0          	lea    -0x20(%rax),%rcx
    16a2:	eb e3                	jmp    1687 <unmapped_area+0x77>
    16a4:	48 8b 41 18          	mov    0x18(%rcx),%rax
    16a8:	48 85 c0             	test   %rax,%rax
    16ab:	74 06                	je     16b3 <unmapped_area+0xa3>
    16ad:	4c 8b 40 08          	mov    0x8(%rax),%r8
    16b1:	eb 03                	jmp    16b6 <unmapped_area+0xa6>
    16b3:	45 31 c0             	xor    %r8d,%r8d
    16b6:	49 39 f8             	cmp    %rdi,%r8
    16b9:	0f 87 86 00 00 00    	ja     1745 <unmapped_area+0x135>
    16bf:	4c 39 d6             	cmp    %r10,%rsi
    16c2:	72 0b                	jb     16cf <unmapped_area+0xbf>
    16c4:	48 89 f0             	mov    %rsi,%rax
    16c7:	4c 29 c0             	sub    %r8,%rax
    16ca:	48 39 d0             	cmp    %rdx,%rax
    16cd:	73 49                	jae    1718 <unmapped_area+0x108>
    16cf:	48 8b 41 28          	mov    0x28(%rcx),%rax
    16d3:	48 85 c0             	test   %rax,%rax
    16d6:	74 06                	je     16de <unmapped_area+0xce>
    16d8:	48 39 50 18          	cmp    %rdx,0x18(%rax)
    16dc:	73 c0                	jae    169e <unmapped_area+0x8e>
    16de:	48 8b 41 20          	mov    0x20(%rcx),%rax
    16e2:	48 8d 71 20          	lea    0x20(%rcx),%rsi
    16e6:	48 83 e0 fc          	and    $0xfffffffffffffffc,%rax
    16ea:	74 18                	je     1704 <unmapped_area+0xf4>
    16ec:	48 3b 70 10          	cmp    0x10(%rax),%rsi
    16f0:	48 8d 48 e0          	lea    -0x20(%rax),%rcx
    16f4:	75 e8                	jne    16de <unmapped_area+0xce>
    16f6:	48 8b 70 f8          	mov    -0x8(%rax),%rsi
    16fa:	4c 8b 46 08          	mov    0x8(%rsi),%r8
    16fe:	48 8b 70 e0          	mov    -0x20(%rax),%rsi
    1702:	eb b2                	jmp    16b6 <unmapped_area+0xa6>
    1704:	4d 8b 41 38          	mov    0x38(%r9),%r8
    1708:	48 c7 c0 f4 ff ff ff 	mov    $0xfffffffffffffff4,%rax
    170f:	49 39 f8             	cmp    %rdi,%r8
    1712:	77 38                	ja     174c <unmapped_area+0x13c>
    1714:	48 83 ce ff          	or     $0xffffffffffffffff,%rsi
    1718:	4d 39 e0             	cmp    %r12,%r8
    171b:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
    1722:	00 00 00=20
    1725:	4d 0f 43 e0          	cmovae %r8,%r12
    1729:	4c 89 e7             	mov    %r12,%rdi
    172c:	ff d0                	callq  *%rax
    172e:	48 85 c0             	test   %rax,%rax
    1731:	4c 0f 45 e0          	cmovne %rax,%r12
    1735:	48 8b 43 28          	mov    0x28(%rbx),%rax
    1739:	4c 29 e0             	sub    %r12,%rax
    173c:	48 23 43 20          	and    0x20(%rbx),%rax
    1740:	4c 01 e0             	add    %r12,%rax
    1743:	eb 07                	jmp    174c <unmapped_area+0x13c>
    1745:	48 c7 c0 f4 ff ff ff 	mov    $0xfffffffffffffff4,%rax
    174c:	5a                   	pop    %rdx
    174d:	59                   	pop    %rcx
    174e:	5b                   	pop    %rbx
    174f:	41 5c                	pop    %r12
    1751:	5d                   	pop    %rbp
    1752:	c3                   	retq  =20

OLD:
0000000000001590 <unmapped_area>:
    1590:	55                   	push   %rbp
    1591:	48 89 e5             	mov    %rsp,%rbp
    1594:	53                   	push   %rbx
    1595:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
    1599:	4c 8b 47 20          	mov    0x20(%rdi),%r8
    159d:	48 25 00 e0 ff ff    	and    $0xffffffffffffe000,%rax
    15a3:	48 8b 00             	mov    (%rax),%rax
    15a6:	4c 89 c6             	mov    %r8,%rsi
    15a9:	48 03 77 08          	add    0x8(%rdi),%rsi
    15ad:	4c 8b 98 b0 01 00 00 	mov    0x1b0(%rax),%r11
    15b4:	48 c7 c0 f4 ff ff ff 	mov    $0xfffffffffffffff4,%rax
    15bb:	0f 82 e8 00 00 00    	jb     16a9 <unmapped_area+0x119>
    15c1:	4c 8b 57 18          	mov    0x18(%rdi),%r10
    15c5:	49 39 f2             	cmp    %rsi,%r10
    15c8:	0f 82 db 00 00 00    	jb     16a9 <unmapped_area+0x119>
    15ce:	4c 8b 4f 10          	mov    0x10(%rdi),%r9
    15d2:	49 29 f2             	sub    %rsi,%r10
    15d5:	4d 39 d1             	cmp    %r10,%r9
    15d8:	0f 87 cb 00 00 00    	ja     16a9 <unmapped_area+0x119>
    15de:	49 8b 43 08          	mov    0x8(%r11),%rax
    15e2:	48 85 c0             	test   %rax,%rax
    15e5:	0f 84 91 00 00 00    	je     167c <unmapped_area+0xec>
    15eb:	49 8b 53 08          	mov    0x8(%r11),%rdx
    15ef:	48 39 72 18          	cmp    %rsi,0x18(%rdx)
    15f3:	0f 82 83 00 00 00    	jb     167c <unmapped_area+0xec>
    15f9:	4a 8d 1c 0e          	lea    (%rsi,%r9,1),%rbx
    15fd:	48 83 ea 20          	sub    $0x20,%rdx
    1601:	48 8b 02             	mov    (%rdx),%rax
    1604:	48 39 d8             	cmp    %rbx,%rax
    1607:	72 15                	jb     161e <unmapped_area+0x8e>
    1609:	48 8b 4a 30          	mov    0x30(%rdx),%rcx
    160d:	48 85 c9             	test   %rcx,%rcx
    1610:	74 0c                	je     161e <unmapped_area+0x8e>
    1612:	48 39 71 18          	cmp    %rsi,0x18(%rcx)
    1616:	72 06                	jb     161e <unmapped_area+0x8e>
    1618:	48 8d 51 e0          	lea    -0x20(%rcx),%rdx
    161c:	eb e3                	jmp    1601 <unmapped_area+0x71>
    161e:	48 8b 4a 18          	mov    0x18(%rdx),%rcx
    1622:	48 85 c9             	test   %rcx,%rcx
    1625:	74 06                	je     162d <unmapped_area+0x9d>
    1627:	48 8b 49 08          	mov    0x8(%rcx),%rcx
    162b:	eb 02                	jmp    162f <unmapped_area+0x9f>
    162d:	31 c9                	xor    %ecx,%ecx
    162f:	4c 39 d1             	cmp    %r10,%rcx
    1632:	77 6e                	ja     16a2 <unmapped_area+0x112>
    1634:	48 39 d8             	cmp    %rbx,%rax
    1637:	72 08                	jb     1641 <unmapped_area+0xb1>
    1639:	48 29 c8             	sub    %rcx,%rax
    163c:	48 39 f0             	cmp    %rsi,%rax
    163f:	73 4b                	jae    168c <unmapped_area+0xfc>
    1641:	48 8b 42 28          	mov    0x28(%rdx),%rax
    1645:	48 85 c0             	test   %rax,%rax
    1648:	74 0c                	je     1656 <unmapped_area+0xc6>
    164a:	48 39 70 18          	cmp    %rsi,0x18(%rax)
    164e:	72 06                	jb     1656 <unmapped_area+0xc6>
    1650:	48 8d 50 e0          	lea    -0x20(%rax),%rdx
    1654:	eb ab                	jmp    1601 <unmapped_area+0x71>
    1656:	48 8b 42 20          	mov    0x20(%rdx),%rax
    165a:	48 8d 4a 20          	lea    0x20(%rdx),%rcx
    165e:	48 83 e0 fc          	and    $0xfffffffffffffffc,%rax
    1662:	74 18                	je     167c <unmapped_area+0xec>
    1664:	48 3b 48 10          	cmp    0x10(%rax),%rcx
    1668:	48 8d 50 e0          	lea    -0x20(%rax),%rdx
    166c:	75 e8                	jne    1656 <unmapped_area+0xc6>
    166e:	48 8b 48 f8          	mov    -0x8(%rax),%rcx
    1672:	48 8b 40 e0          	mov    -0x20(%rax),%rax
    1676:	48 8b 49 08          	mov    0x8(%rcx),%rcx
    167a:	eb b3                	jmp    162f <unmapped_area+0x9f>
    167c:	49 8b 4b 38          	mov    0x38(%r11),%rcx
    1680:	48 c7 c0 f4 ff ff ff 	mov    $0xfffffffffffffff4,%rax
    1687:	4c 39 d1             	cmp    %r10,%rcx
    168a:	77 1d                	ja     16a9 <unmapped_area+0x119>
    168c:	48 8b 47 28          	mov    0x28(%rdi),%rax
    1690:	4c 39 c9             	cmp    %r9,%rcx
    1693:	49 0f 42 c9          	cmovb  %r9,%rcx
    1697:	48 29 c8             	sub    %rcx,%rax
    169a:	4c 21 c0             	and    %r8,%rax
    169d:	48 01 c8             	add    %rcx,%rax
    16a0:	eb 07                	jmp    16a9 <unmapped_area+0x119>
    16a2:	48 c7 c0 f4 ff ff ff 	mov    $0xfffffffffffffff4,%rax
    16a9:	5b                   	pop    %rbx
    16aa:	5d                   	pop    %rbp
    16ab:	c3                   	retq  =20

<snip>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
