Date: Mon, 14 Oct 2002 05:20:14 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: 2.5.42-mm2 munmap() oops
Message-ID: <20021014122014.GI2032@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: dmccr@us.ibm.com
List-ID: <linux-mm.kvack.org>

Well, I was just vi'ing kernel source etc. on 2.5.42-mm2 + fixes, and
this seemed to happen:

Bill

int3: 0000

CPU:    9
EIP:    0060:[<c012fee2>]    Not tainted
EFLAGS: 00000202
EIP is at zap_pmd_range+0xd6/0x10c
eax: 00000002   ebx: ef4c9010   ecx: c0434000   edx: 00491000
esi: f4f7fb78   edi: 40200000   ebp: ebe3ff10   esp: ebe3fef8
ds: 0068   es: 0068   ss: 0068
Process vi (pid: 569, threadinfo=ebe3e000 task=ee30c740)
Stack: 40133000 ee1959c8 40691000 40400000 40691000 ef4c9008 ebe3ff34 c012ff50
       c03b047c ee1959c8 40133000 0055e000 40691000 40133000 ec03b540 ebe3ff5c
       c0133d72 c03b047c ec03b540 40133000 40691000 ebf71e50 ebf71e50 ec03b540
Call Trace:
 [<c012ff50>] unmap_page_range+0x38/0x5c
 [<c0133d72>] unmap_region+0xe2/0x174
 [<c0134087>] do_munmap+0x12b/0x160
 [<c0134101>] sys_munmap+0x45/0x64
 [<c010732f>] syscall_call+0x7/0xb

Code: 52 57 8b 4d fc 51 8b 45 08 50 e8 eb fb ff ff 83 c4 10 f0 0f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
