Subject: Re: [PATCH 2.5.41-mm3] Fix unmap for shared page tables
From: Paul Larson <plars@linuxtestproject.org>
In-Reply-To: <65780000.1034356238@baldur.austin.ibm.com>
References: <65780000.1034356238@baldur.austin.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 11 Oct 2002 14:24:55 -0500
Message-Id: <1034364296.9904.4.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2002-10-11 at 12:10, Dave McCracken wrote:
> 
> I realized I got the unmap code wrong for shared page tables.  Here's a
> patch that fixes the problem plus optimizes the exit case.  It should also
> fix Paul Larson's BUG().
I tried 2.5.41-mm3+this patch and got a LOT of errors during boot, and
periodically while it was running (it did boot though).  Test machine
was pIII-700, 16 GB and I didn't run LTP since I don't think I could see
through all the other stuff if it did produce a BUG or an oops.  Here is
a snip of some of it, along with random garbage it spit out over the
serial console.  It looked like maybe crond was unhappy with something. 
Ksymoops didn't seem happy trying to extract anything else from this.
I tried 2.5.41-mm3 by itself and did not get this.

Thanks,
Paul Larson

Unable to handle kernel paging request at virtual address 4212e3b0
 printing eip:
4207ac55
*pde = 5a5a5a5a
Oops: 0007

CPU:    0
EIP:    0023:[<4207ac55>]    Not tainted
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1149, threadinfo=f6ea2000 task=f63ca080)
 <6>note: crond[1149] exited with preempt_count 1
Unable to handle kernel paging request at virtual address 4212e3b0
 printing eip:
4207ac55
*pde = 00000000
Oops: 0007

CPU:    0
EIP:    0023:[<4207ac55>]    Not tainted
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1150, threadinfo=f63ba000 task=f6c006a0)
 <6>note: crond[1150] exited with preempt_count 1
Unable to handle kernel paging request at virtual address 4212e3b0
 printing eip:
4207ac55
*pde = 5a5a5a5a
Oops: 0007

CPU:    0
EIP:    0023:[<4207ac55>]    Not tainted
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1151, threadinfo=f63c2000 task=f7c92d20)
 <6>note: crond[1151] exited with preempt_count 1
Unable to handle kernel paging request at virtual address 4212e3b0
 printing eip:
4207ac55
*pde = 5a5a5a5a
Oops: 0007

CPU:    0
EIP:    0023:[<4207ac55>]    Not tainted
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1152, threadinfo=f638a000 task=f6b0b9a0)
 <6>note: crond[1152] exited with preempt_count 1
Unab<<<1l1>>e1U>UUn tnnabaaolbbl ee thalo e tn dolt hhaneaon 
ddkhllaeene rd nklkeeeerrl knn erepenl lae ppaalggg iinginpgna r eggre
iqrueeqnsuqgt ueersest qattu< v4esi> t<r4ta><uta4  al >t va idatvr
itdrvuesritrasutal  ula42a1dl 2 daderadde3brsdres0 se4s
s122  ep4123rb12in02e
bbng00 p             tei33

riin p :tpirpin
nrgti4 i2nn0egit7 aipe:cinp
g5 :54
      2
07p4*:2ap
c5e      c057ad
54  5
 *5pa0d*75eaa p5dc= ae55 55=aa
                              5
*55apOad5e5 aoa
as             =p5
a050a05a7
         5a

CPU:    0
EIP:    0023:[<4207ac55>]    Not tainted
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1153, threadinfo=f637a000 task=f63ca080)
 O<o6ps>:no 0t0e:0 7
on d                cr
[11CP5U3:]  e x  i1t
 wEiIPth:  p r  e0em0p2t3:_c[<o4un2t0 71ac
5>]    Not tainted                        5
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1156, threadinfo=f6374000 task=f6c006a0)
 O<op6>sn: o0t0e0:7
ro n                c
[1C1P56U]:  e  xi 2te
 wEiItPh:   pr e 0e0m2p3t_:c[<ou4n2t07 1a
55>]    Not tainted                      c
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1155, threadinfo=f6376000 task=f6bed340)
 O<op6s:> n0ot00e:7
r on                c
d[C1P15U5: ]   ex i4
d EIwPit:h   p  r0e0em2p3:t[_c<o4u2n07t ac15
>]    Not tainted                           5
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1154, threadinfo=f6378000 task=f6bec6c0)
 <6>note: crond[1154] exited with preempt_count 1
Unable to handle kernel paging request at virtual address 4212e3b0
 printing eip:
4207ac55
*pde = 5a5a5a5a
Oops: 0007

CPU:    0
EIP:    0023:[<4207ac55>]    Not tainted
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1212, threadinfo=f62f8000 task=f6c006a0)
 <6>note: crond[1212] exited with preempt_count 1
Unable to handle kernel paging request at virtual address 4212e3b0
 printing eip:
4207ac55
*pde = 00360833
Oops: 0007

CPU:    0
EIP:    0023:[<4207ac55>]    Not tainted
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1273, threadinfo=f6252000 task=cc175340)
 <6>note: crond[1273] exited with preempt_count 1
Unable to handle kernel paging request at virtual address 4212e3b0
 printing eip:
4207ac55
*pde = 00000000
Oops: 0007

CPU:    0
EIP:    0023:[<4207ac55>]    Not tainted
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1275, threadinfo=f6214000 task=f63cb340)
 <6>note: crond[1275] exited with preempt_count 1
bad: scheduling while atomic!
Call Trace:
 [<c011614f>] do_schedule+0x2f/0x380
 [<c012f024>] sys_munmap+0x44/0x70
 [<c01071fa>] work_resched+0x5/0x16

Unable to handle kernel paging request at virtual address 4212e3b0
 printing eip:
4207ac55
*pde = 5a5a5a5a
Oops: 0007

CPU:    0
EIP:    0023:[<4207ac55>]    Not tainted
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1280, threadinfo=f61c2000 task=cc175980)
 <6>note: crond[1280] exited with preempt_count 1
Una<<b1>leU1 >nUatnbaol hbalee  nttdloo eh ak ehnrdannleedll ek e
krneprnaeegli lp apnaggg iirnneg qrgu eqreseuteqsuet a<stt v4i> r<att4u
>val i arattd udvalirr etassd u4d2ar1l2 esae3ddsb0r
ss2  p412r2in12teei3nb3g b0   e4
e                          0
 p:p r
irinnt4it2nig ne0g 7aeiipc5:p5
                              :

4*<2p407>ad42e0 =7a cc5055050
                             0
000*0p<d1
>* =Op o5pdase5 =:a  5a00500a00
0700
00

CPU:    0
EIP:    0023:[<4207ac55>]    Not tainted
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1284, threadinfo=f6c7a000 task=f6b0b9a0)
 O<o6ps>n:o 0te00: 7
ron d               c
[12C8PU4]:   e xi t5
d EwiItPh:   pr e 0e0mp23t_:[co<4un2t07 1a
55>]    Not tainted                       c
EFLAGS: 00010246
EIP is at E Using_Versions+0x4207ac54/0xc011a67f
eax: 00000001   ebx: 4213030c   ecx: 00000000   edx: 00000000
esi: 0804e020   edi: 4212dfa0   ebp: bffffba8   esp: bffffb90
ds: 002b   es: 002b   ss: 002b
Process crond (pid: 1285, threadinfo=f6182000 task=f6caa040)
 O<o6p>s:n ot0e0:0 7c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
