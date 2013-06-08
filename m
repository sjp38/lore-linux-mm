Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 6E9DC6B0031
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 21:13:51 -0400 (EDT)
Message-ID: <51B28531.2050403@huawei.com>
Date: Sat, 8 Jun 2013 09:13:21 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: Transparent Hugepage impact on memcpy
References: <51ADAC15.1050103@huawei.com> <51AEAFD8.305@huawei.com> <CAMO-S2ixv55bGEFGR6Eh=UZgVBz=nv81EckuzWoVi0t4KdB+VA@mail.gmail.com> <51B136E2.4010606@huawei.com> <87txlado8e.wl%mitake.hitoshi@gmail.com>
In-Reply-To: <87txlado8e.wl%mitake.hitoshi@gmail.com>
Content-Type: multipart/mixed;
	boundary="------------040503040505000904030603"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hitoshi Mitake <mitake.hitoshi@gmail.com>
Cc: Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, qiuxishi <qiuxishi@huawei.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hush Bensen <hush.bensen@gmail.com>

--------------040503040505000904030603
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi Hitoshi,

On 2013/6/7 21:50, Hitoshi Mitake wrote:

> At Fri, 7 Jun 2013 09:26:58 +0800,
> Jianguo Wu wrote:
>>
>> Hi Hitoshi,
>>
>> Thanks for your reply! please see below.
>>
>> On 2013/6/6 21:54, Hitoshi Mitake wrote:
>>
>>> Hi Jianguo,
>>>
>>> On Wed, Jun 5, 2013 at 12:26 PM, Jianguo Wu <wujianguo@huawei.com> wrote:
>>>> Hi,
>>>> One more question, I wrote a memcpy test program, mostly the same as with perf bench memcpy.
>>>> But test result isn't consistent with perf bench when THP is off.
>>>>
>>>>         my program                              perf bench
>>>> THP:    3.628368 GB/Sec (with prefault)         3.672879 GB/Sec (with prefault)
>>>> NO-THP: 3.612743 GB/Sec (with prefault)         6.190187 GB/Sec (with prefault)
>>>>
>>>> Below is my code:
>>>>         src = calloc(1, len);
>>>>         dst = calloc(1, len);
>>>>
>>>>         if (prefault)
>>>>                 memcpy(dst, src, len);
>>>>         gettimeofday(&tv_start, NULL);
>>>>         memcpy(dst, src, len);
>>>>         gettimeofday(&tv_end, NULL);
>>>>
>>>>         timersub(&tv_end, &tv_start, &tv_diff);
>>>>         free(src);
>>>>         free(dst);
>>>>
>>>>         speed = (double)((double)len / timeval2double(&tv_diff));
>>>>         print_bps(speed);
>>>>
>>>> This is weird, is it possible that perf bench do some build optimize?
>>>>
>>>> Thansk,
>>>> Jianguo Wu.
>>>
>>> perf bench mem memcpy is build with -O6. This is the compile command
>>> line (you can get this with make V=1):
>>> gcc -o bench/mem-memcpy-x86-64-asm.o -c -fno-omit-frame-pointer -ggdb3
>>> -funwind-tables -Wall -Wextra -std=gnu99 -Werror -O6 .... # ommited
>>>
>>> Can I see your compile option for your test program and the actual
>>> command line executing perf bench mem memcpy?
>>>
>>
>> I just compiled my test program with gcc -o memcpy-test memcpy-test.c.
>> I tried to use the same compile option with perf bench mem memcpy, and
>> the test result showed no difference.
>>
>> My execute command line for perf bench mem memcpy:
>> #./perf bench mem memcpy -l 1gb -o
> 
> Thanks for your information. I have three more requests for
> reproducing the problem:
> 
> 1. the entire source code of your program

Please see the attachment.

> 2. your gcc version

4.3.4

> 3. your glibc version

glibc-2.11.1-0.17.4

Thanks,
Jianguo Wu

> 
> I should've requested it first, sorry :(
> 
> Thanks,
> Hitoshi
> 
> .
> 



--------------040503040505000904030603
Content-Type: text/plain; charset="gb18030"; name="memcpy-prefault.c"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="memcpy-prefault.c"

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHN0cmlu
Zy5oPgojaW5jbHVkZSA8c3lzL3RpbWUuaD4KI2luY2x1ZGUgPHVuaXN0ZC5oPgoKI2RlZmlu
ZSBLIDEwMjRMTAojZGVmaW5lIHByaW50X2Jwcyh4KSBkbyB7CQkJCQlcCgkJaWYgKHggPCBL
KQkJCQkJXAoJCQlwcmludGYoIiAlMTRsZiBCL1NlYyIsIHgpOwkJXAoJCWVsc2UgaWYgKHgg
PCBLICogSykJCQkJXAoJCQlwcmludGYoIiAlMTRsZmQgS0IvU2VjIiwgeCAvIEspOwlcCgkJ
ZWxzZSBpZiAoeCA8IEsgKiBLICogSykJCQkJXAoJCQlwcmludGYoIiAlMTRsZiBNQi9TZWMi
LCB4IC8gSyAvIEspOwlcCgkJZWxzZQkJCQkJCVwKCQkJcHJpbnRmKCIgJTE0bGYgR0IvU2Vj
IiwgeCAvIEsgLyBLIC8gSyk7IFwKCX0gd2hpbGUgKDApCgpsb25nIGxvbmcgbG9jYWxfYXRv
bGwoY29uc3QgY2hhciAqc3RyKQp7Cgl1bnNpZ25lZCBpbnQgaTsKCWxvbmcgbG9uZyBsZW5n
dGggPSAtMSwgdW5pdCA9IDE7CgoJaWYgKCFpc2RpZ2l0KHN0clswXSkpCgkJZ290byBvdXRf
ZXJyOwoKCWZvciAoaSA9IDE7IGkgPCBzdHJsZW4oc3RyKTsgaSsrKSB7CgkJc3dpdGNoIChz
dHJbaV0pIHsKCQljYXNlICdCJzoKCQljYXNlICdiJzoKCQkJYnJlYWs7CgkJY2FzZSAnSyc6
CgkJCWlmIChzdHJbaSArIDFdICE9ICdCJykKCQkJCWdvdG8gb3V0X2VycjsKCQkJZWxzZQoJ
CQkJZ290byBraWxvOwoJCWNhc2UgJ2snOgoJCQlpZiAoc3RyW2kgKyAxXSAhPSAnYicpCgkJ
CQlnb3RvIG91dF9lcnI7CmtpbG86CgkJCXVuaXQgPSBLOwoJCQlicmVhazsKCQljYXNlICdN
JzoKCQkJaWYgKHN0cltpICsgMV0gIT0gJ0InKQoJCQkJZ290byBvdXRfZXJyOwoJCQllbHNl
CgkJCQlnb3RvIG1lZ2E7CgkJY2FzZSAnbSc6CgkJCWlmIChzdHJbaSArIDFdICE9ICdiJykK
CQkJCWdvdG8gb3V0X2VycjsKbWVnYToKCQkJdW5pdCA9IEsgKiBLOwoJCQlicmVhazsKCQlj
YXNlICdHJzoKCQkJaWYgKHN0cltpICsgMV0gIT0gJ0InKQoJCQkJZ290byBvdXRfZXJyOwoJ
CQllbHNlCgkJCQlnb3RvIGdpZ2E7CgkJY2FzZSAnZyc6CgkJCWlmIChzdHJbaSArIDFdICE9
ICdiJykKCQkJCWdvdG8gb3V0X2VycjsKZ2lnYToKCQkJdW5pdCA9IEsgKiBLICogSzsKCQkJ
YnJlYWs7CgkJY2FzZSAnVCc6CgkJCWlmIChzdHJbaSArIDFdICE9ICdCJykKCQkJCWdvdG8g
b3V0X2VycjsKCQkJZWxzZQoJCQkJZ290byB0ZXJhOwoJCWNhc2UgJ3QnOgoJCQlpZiAoc3Ry
W2kgKyAxXSAhPSAnYicpCgkJCQlnb3RvIG91dF9lcnI7CnRlcmE6CgkJCXVuaXQgPSBLICog
SyAqIEsgKiBLOwoJCQlicmVhazsKCQljYXNlICdcMCc6CS8qIG9ubHkgc3BlY2lmaWVkIGZp
Z3VyZXMgKi8KCQkJdW5pdCA9IDE7CgkJCWJyZWFrOwoJCWRlZmF1bHQ6CgkJCWlmICghaXNk
aWdpdChzdHJbaV0pKQoJCQkJZ290byBvdXRfZXJyOwoJCQlicmVhazsKCQl9Cgl9CgoJbGVu
Z3RoID0gYXRvbGwoc3RyKSAqIHVuaXQ7Cglnb3RvIG91dDsKCm91dF9lcnI6CglsZW5ndGgg
PSAtMTsKb3V0OgoJcmV0dXJuIGxlbmd0aDsKfQoKc3RhdGljIGRvdWJsZSB0aW1ldmFsMmRv
dWJsZShzdHJ1Y3QgdGltZXZhbCAqdHMpCnsKCXJldHVybiAoZG91YmxlKXRzLT50dl9zZWMg
KwoJCQkoZG91YmxlKXRzLT50dl91c2VjIC8gKGRvdWJsZSkxMDAwMDAwOwp9Cgp2b2lkIGRv
X21lbWNweShsb25nIGxvbmcgbGVuLCBpbnQgcHJlZmF1bHQpCnsKCXZvaWQgKnNyYywgKmRz
dDsKCXN0cnVjdCB0aW1ldmFsIHR2X3N0YXJ0LCB0dl9lbmQsIHR2X2RpZmY7Cglkb3VibGUg
cmVzOwoKCXNyYyA9IGNhbGxvYygxLCBsZW4pOwoJZHN0ID0gY2FsbG9jKDEsIGxlbik7CgoJ
aWYgKHByZWZhdWx0KQoJCW1lbWNweShkc3QsIHNyYywgbGVuKTsKCWdldHRpbWVvZmRheSgm
dHZfc3RhcnQsIE5VTEwpOwoJbWVtY3B5KGRzdCwgc3JjLCBsZW4pOwoJZ2V0dGltZW9mZGF5
KCZ0dl9lbmQsIE5VTEwpOwoKCXRpbWVyc3ViKCZ0dl9lbmQsICZ0dl9zdGFydCwgJnR2X2Rp
ZmYpOwoJZnJlZShzcmMpOwoJZnJlZShkc3QpOwoKCXJlcyA9IChkb3VibGUpKChkb3VibGUp
bGVuIC8gdGltZXZhbDJkb3VibGUoJnR2X2RpZmYpKTsKCXByaW50X2JwcyhyZXMpOwoJaWYg
KHByZWZhdWx0KQoJCXByaW50ZigiXHQod2l0aCBwcmVmYXVsdCkiKTsKCXByaW50ZigiXG4i
KTsKCn0KCmludCBtYWluKGludCBhcmdjLCBjaGFyICphcmd2W10pCnsKCWxvbmcgbG9uZyBs
ZW4gPSAtMTsgCgljaGFyIGNoOwoJaW50IHByZWZhdWx0ID0gMDsKCgl3aGlsZSggKGNoPWdl
dG9wdChhcmdjLCBhcmd2LCAibDoiKSApICE9IC0xICkgIAoJeyAgCgkJc3dpdGNoKGNoKSAg
CgkJeyAgCgkJCWNhc2UgJ2wnOgoJCQkJbGVuID0gbG9jYWxfYXRvbGwob3B0YXJnKTsKCQkJ
CWlmIChsZW4gPCAwKSB7CgkJCQkJcHJpbnRmKCJJbnZhbGlkIHNpemVcbiIpOwoJCQkJCXJl
dHVybiAwOwoJCQkJfSBlbHNlCQkJCQoJCQkJCXByaW50ZigiIyBDb3B5aW5nICVzIEJ5dGUg
Li4uXG4iLCBvcHRhcmcpOwoJCQkJYnJlYWs7CgkJCWRlZmF1bHQ6CgkJCQlyZXR1cm47CgkJ
fQoJfQoKCWRvX21lbWNweShsZW4sIDEpOwkKCQoJcmV0dXJuIDA7Cn0K
--------------040503040505000904030603--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
