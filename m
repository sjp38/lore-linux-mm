From: Ed Tomlinson <tomlins@cam.org>
Subject: [opps] 2.5.64-mm1
Date: Tue, 11 Mar 2003 17:46:52 -0500
References: <20030305230712.5a0ec2d4.akpm@digeo.com> <87y93pgek8.fsf@lapper.ihatent.com>
In-Reply-To: <87y93pgek8.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200303111746.52955.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Got home this afternoon and found my box has paniced with:

Unable to handle kernel NULL pointer dereference at virtual address 0000003c
 printing eip:
c011372b
*pde = 00000000
Oops: 0000
CPU:    0
EIP:    0060:[<c011372b>]    Not tainted
EFLAGS: 00010007
EIP is at do_schedule+0x193/0x330
eax: dff8a000   ebx: ffffffe0   ecx: c030e0a0   edx: 00000003
esi: dff8c660   edi: 00000000   ebp: dff8bfdc   esp: dff8bfc4
ds: 007b   es: 007b   ss: 0068
Process ksoftirqd/0 (pid: 2, threadinfo=dff8a000 task=dff8c660)
Stack: dff8a000 dff8a000 00000000 dff8a000 00000000 dff8c660 dff8bfec c011a3be 
       c011a358 00000000 00000000 c01070e9 00000000 00000000 00000000 
Call Trace:
 [<c011a3be>] ksoftirqd+0x66/0xa4
 [<c011a358>] ksoftirqd+0x0/0xa4
 [<c01070e9>] kernel_thread_helper+0x5/0xc

Code: 8b 53 5c 8b 7e 60 85 d2 75 0b 89 7b 60 ff 47 18 eb 78 8d 76 

and feeding the eip and code to ksymoops:

>>EIP; c011372b <do_schedule+193/330>   <=====

Code;  c011372b <do_schedule+193/330>
00000000 <_EIP>:
Code;  c011372b <do_schedule+193/330>   <=====
   0:   8b 53 5c                  mov    0x5c(%ebx),%edx   <=====
Code;  c011372e <do_schedule+196/330>
   3:   8b 7e 60                  mov    0x60(%esi),%edi
Code;  c0113731 <do_schedule+199/330>
   6:   85 d2                     test   %edx,%edx
Code;  c0113733 <do_schedule+19b/330>
   8:   75 0b                     jne    15 <_EIP+0x15>
Code;  c0113735 <do_schedule+19d/330>
   a:   89 7b 60                  mov    %edi,0x60(%ebx)
Code;  c0113738 <do_schedule+1a0/330>
   d:   ff 47 18                  incl   0x18(%edi)
Code;  c011373b <do_schedule+1a3/330>
  10:   eb 78                     jmp    8a <_EIP+0x8a>
Code;  c011373d <do_schedule+1a5/330>
  12:   8d 76 00                  lea    0x0(%esi),%esi

Does this ring bells anywhere?

Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
