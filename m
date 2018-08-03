Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACAD6B000D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 19:21:44 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j9-v6so5428778qtn.22
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 16:21:44 -0700 (PDT)
Received: from outgoing-stata.csail.mit.edu (outgoing-stata.csail.mit.edu. [128.30.2.210])
        by mx.google.com with ESMTP id f3-v6si440810qvi.172.2018.08.03.16.21.43
        for <linux-mm@kvack.org>;
        Fri, 03 Aug 2018 16:21:43 -0700 (PDT)
Subject: Re: [RESEND] Spectre-v2 (IBPB/IBRS) and SSBD fixes for 4.4.y
References: <153156030832.10043.13438231886571087086.stgit@srivatsa-ubuntu>
 <nycvar.YFH.7.76.1807232357440.997@cbobk.fhfr.pm>
 <e57d5ac9-68d7-8ccf-6117-5a2f9d9e1112@csail.mit.edu>
 <nycvar.YFH.7.76.1807242351500.997@cbobk.fhfr.pm>
 <CAGXu5jJvTF0KXs+3J32u5v1Ba5gZd0Umgib6D6++ie+LzqnuWA@mail.gmail.com>
 <c616c38b-52cc-2f88-7ea3-00f3a572255a@csail.mit.edu>
 <CAGXu5j+Y5TNBY1WCz=4E8B5nFo2jzyswg6iaQja_92GZB+hE0w@mail.gmail.com>
From: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Message-ID: <8a87a705-97c0-eb3d-8878-8ffe052f065d@csail.mit.edu>
Date: Fri, 3 Aug 2018 16:20:31 -0700
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+Y5TNBY1WCz=4E8B5nFo2jzyswg6iaQja_92GZB+hE0w@mail.gmail.com>
Content-Type: multipart/mixed;
 boundary="------------6AAF02DB08CAA2E0F2C8324B"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Jiri Kosina <jikos@kernel.org>, Greg KH <gregkh@linuxfoundation.org>, "# 3.4.x" <stable@vger.kernel.org>, Denys Vlasenko <dvlasenk@redhat.com>, Bo Gan <ganb@vmware.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Andi Kleen <ak@linux.intel.com>, linux-tip-commits@vger.kernel.org, Jia Zhang <qianyue.zj@alibaba-inc.com>, Josh Poimboeuf <jpoimboe@redhat.com>, xen-devel <xen-devel@lists.xenproject.org>, =?UTF-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@amacapital.net>, Arnaldo Carvalho de Melo <acme@redhat.com>, Sherry Hurwitz <sherry.hurwitz@amd.com>, LKML <linux-kernel@vger.kernel.org>, Shuah Khan <shuahkh@osg.samsung.com>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, KarimAllah Ahmed <karahmed@amazon.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Joerg Roedel <joro@8bytes.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Kyle Huey <me@kylehuey.com>, Will Drewry <wad@chromium.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Brian Gerst <brgerst@gmail.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Thomas Garnier <thgarnie@google.com>, Andrew Morton <akpm@linux-foundation.org>, Joe Konno <joe.konno@linux.intel.com>, kvm <kvm@vger.kernel.org>, Piotr Luc <piotr.luc@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Jan Beulich <jbeulich@suse.com>, Arjan van de Ven <arjan@linux.intel.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, Juergen Gross <jgross@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?Q?J=c3=b6rg_Otte?= <jrg.otte@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alexander Sergeyev <sergeev917@gmail.com>, Josh Triplett <josh@joshtriplett.org>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Tony Luck <tony.luck@intel.com>, Laura Abbott <labbott@fedoraproject.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexey Makhalov <amakhalov@vmware.com>, Dave Hansen <dave@sr71.net>, ashok.raj@intel.com, Mel Gorman <mgorman@suse.de>, =?UTF-8?B?TWlja2HDq2xTYWxhw7xu?= <mic@digikod.net>, Fenghua Yu <fenghua.yu@intel.com>, "Matt Helsley (VMware)" <matt.helsley@gmail.com>, Vince Weaver <vincent.weaver@maine.edu>, Prarit Bhargava <prarit@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Dan Williams <dan.j.williams@intel.com>, Jim Mattson <jmattson@google.com>, Greg Kroah-Hartmann <gregkh@linux-foundation.org>, Dave Young <dyoung@redhat.com>, linux-edac <linux-edac@vger.kernel.org>, Jon Masters <jcm@redhat.com>, Andy Lutomirski <luto@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Linux-MM <linux-mm@kvack.org>, Jiri Olsa <jolsa@redhat.com>, "Van De Ven, Arjan" <arjan.van.de.ven@intel.com>, sironi@amazon.de, Frederic Weisbecker <fweisbec@gmail.com>, Kyle Huey <khuey@kylehuey.com>, Alexander Popov <alpopov@ptsecurity.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Nadav Amit <nadav.amit@gmail.com>, Yazen Ghannam <Yazen.Ghannam@amd.com>, Wanpeng Li <kernellwp@gmail.com>, Stephane Eranian <eranian@google.com>, David Woodhouse <dwmw2@infradead.org>, srivatsab@vmware.com, srinidhir@vmware.com, khlebnikov@yandex-team.ru, catalin.marinas@arm.com

This is a multi-part message in MIME format.
--------------6AAF02DB08CAA2E0F2C8324B
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 8/2/18 3:22 PM, Kees Cook wrote:
> On Thu, Aug 2, 2018 at 12:22 PM, Srivatsa S. Bhat
> <srivatsa@csail.mit.edu> wrote:
>> On 7/26/18 4:09 PM, Kees Cook wrote:
>>> On Tue, Jul 24, 2018 at 3:02 PM, Jiri Kosina <jikos@kernel.org> wrote:
>>>> On Tue, 24 Jul 2018, Srivatsa S. Bhat wrote:
>>>>
>>>>> However, if you are proposing that you'd like to contribute the enhanced
>>>>> PTI/Spectre (upstream) patches from the SLES 4.4 tree to 4.4 stable, and
>>>>> have them merged instead of this patch series, then I would certainly
>>>>> welcome it!
>>>>
>>>> I'd in principle love us to push everything back to 4.4, but there are a
>>>> few reasons (*) why that's not happening shortly.
>>>>
>>>> Anyway, to point out explicitly what's really needed for those folks
>>>> running 4.4-stable and relying on PTI providing The Real Thing(TM), it's
>>>> either a 4.4-stable port of
>>>>
>>>>         http://kernel.suse.com/cgit/kernel-source/plain/patches.suse/x86-entry-64-use-a-per-cpu-trampoline-stack.patch?id=3428a77b02b1ba03e45d8fc352ec350429f57fc7
>>>>
>>>> or making THREADINFO_GFP imply __GFP_ZERO.
>>>
>>> This is true in Linus's tree now. Should be trivial to backport:
>>> https://git.kernel.org/linus/e01e80634ecdd
>>>
>>
>> Hi Jiri, Kees,
>>
>> Thank you for suggesting the patch! I have attached the (locally
>> tested) 4.4 and 4.9 backports of that patch with this mail. (The
>> mainline commit applies cleanly on 4.14).
>>
>> Greg, could you please consider including them in stable 4.4, 4.9
>> and 4.14?
> 
> I don't think your v4.9 is sufficient: it leaves the vmapped stack
> uncleared. v4.9 needs ca182551857 ("kmemleak: clear stale pointers
> from task stacks") included in the backport (really, just adding the
> memset()).
> 

Ah, I see, thank you! I have attached the updated patchset for 4.9
with this mail.

> Otherwise, yup, looks good.
> 
Thank you for reviewing the patches!
 
Regards,
Srivatsa
VMware Photon OS

--------------6AAF02DB08CAA2E0F2C8324B
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="4.9-0001-kmemleak-clear-stale-pointers-from-task-stacks.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename*0="4.9-0001-kmemleak-clear-stale-pointers-from-task-stacks.patc";
 filename*1="h"

RnJvbSBlZGY4MzVkOGI2YmFjMDhiYzVlNjllZmIzZTFjYzMyMWUyNDU3ZjYxIE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBLb25zdGFudGluIEtobGVibmlrb3YgPGtobGVibmlr
b3ZAeWFuZGV4LXRlYW0ucnU+CkRhdGU6IEZyaSwgMTMgT2N0IDIwMTcgMTU6NTg6MjIgLTA3
MDAKU3ViamVjdDogW1BBVENIIDEvMl0ga21lbWxlYWs6IGNsZWFyIHN0YWxlIHBvaW50ZXJz
IGZyb20gdGFzayBzdGFja3MKCmNvbW1pdCBjYTE4MjU1MTg1N2NjMmMxZTZhMmI3ZjFlNzIw
OTBhMTM3YTE1MDA4IHVwc3RyZWFtLgoKS21lbWxlYWsgY29uc2lkZXJzIGFueSBwb2ludGVy
cyBvbiB0YXNrIHN0YWNrcyBhcyByZWZlcmVuY2VzLiAgVGhpcwpwYXRjaCBjbGVhcnMgbmV3
bHkgYWxsb2NhdGVkIGFuZCByZXVzZWQgdm1hcCBzdGFja3MuCgpMaW5rOiBodHRwOi8vbGtt
bC5rZXJuZWwub3JnL3IvMTUwNzI4OTkwMTI0Ljc0NDE5OS44NDAzNDA5ODM2Mzk0MzE4Njg0
LnN0Z2l0QGJ1enoKU2lnbmVkLW9mZi1ieTogS29uc3RhbnRpbiBLaGxlYm5pa292IDxraGxl
Ym5pa292QHlhbmRleC10ZWFtLnJ1PgpBY2tlZC1ieTogQ2F0YWxpbiBNYXJpbmFzIDxjYXRh
bGluLm1hcmluYXNAYXJtLmNvbT4KU2lnbmVkLW9mZi1ieTogQW5kcmV3IE1vcnRvbiA8YWtw
bUBsaW51eC1mb3VuZGF0aW9uLm9yZz4KU2lnbmVkLW9mZi1ieTogTGludXMgVG9ydmFsZHMg
PHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRpb24ub3JnPgpbIFNyaXZhdHNhOiBCYWNrcG9ydGVk
IHRvIDQuOS55IF0KU2lnbmVkLW9mZi1ieTogU3JpdmF0c2EgUy4gQmhhdCA8c3JpdmF0c2FA
Y3NhaWwubWl0LmVkdT4KLS0tCiBpbmNsdWRlL2xpbnV4L3RocmVhZF9pbmZvLmggfCAyICst
CiBrZXJuZWwvZm9yay5jICAgICAgICAgICAgICAgfCA0ICsrKysKIDIgZmlsZXMgY2hhbmdl
ZCwgNSBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pCgpkaWZmIC0tZ2l0IGEvaW5jbHVk
ZS9saW51eC90aHJlYWRfaW5mby5oIGIvaW5jbHVkZS9saW51eC90aHJlYWRfaW5mby5oCmlu
ZGV4IDI4NzNiYWYuLmNmODdjMTYgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvdGhyZWFk
X2luZm8uaAorKysgYi9pbmNsdWRlL2xpbnV4L3RocmVhZF9pbmZvLmgKQEAgLTU5LDcgKzU5
LDcgQEAgZXh0ZXJuIGxvbmcgZG9fbm9fcmVzdGFydF9zeXNjYWxsKHN0cnVjdCByZXN0YXJ0
X2Jsb2NrICpwYXJtKTsKIAogI2lmZGVmIF9fS0VSTkVMX18KIAotI2lmZGVmIENPTkZJR19E
RUJVR19TVEFDS19VU0FHRQorI2lmIElTX0VOQUJMRUQoQ09ORklHX0RFQlVHX1NUQUNLX1VT
QUdFKSB8fCBJU19FTkFCTEVEKENPTkZJR19ERUJVR19LTUVNTEVBSykKICMgZGVmaW5lIFRI
UkVBRElORk9fR0ZQCQkoR0ZQX0tFUk5FTF9BQ0NPVU5UIHwgX19HRlBfTk9UUkFDSyB8IFwK
IAkJCQkgX19HRlBfWkVSTykKICNlbHNlCmRpZmYgLS1naXQgYS9rZXJuZWwvZm9yay5jIGIv
a2VybmVsL2ZvcmsuYwppbmRleCA3MGUxMGNiLi5jMTllNmQ0IDEwMDY0NAotLS0gYS9rZXJu
ZWwvZm9yay5jCisrKyBiL2tlcm5lbC9mb3JrLmMKQEAgLTE4NCw2ICsxODQsMTAgQEAgc3Rh
dGljIHVuc2lnbmVkIGxvbmcgKmFsbG9jX3RocmVhZF9zdGFja19ub2RlKHN0cnVjdCB0YXNr
X3N0cnVjdCAqdHNrLCBpbnQgbm9kZSkKIAkJCWNvbnRpbnVlOwogCQl0aGlzX2NwdV93cml0
ZShjYWNoZWRfc3RhY2tzW2ldLCBOVUxMKTsKIAorI2lmZGVmIENPTkZJR19ERUJVR19LTUVN
TEVBSworCQkvKiBDbGVhciBzdGFsZSBwb2ludGVycyBmcm9tIHJldXNlZCBzdGFjay4gKi8K
KwkJbWVtc2V0KHMtPmFkZHIsIDAsIFRIUkVBRF9TSVpFKTsKKyNlbmRpZgogCQl0c2stPnN0
YWNrX3ZtX2FyZWEgPSBzOwogCQlsb2NhbF9pcnFfZW5hYmxlKCk7CiAJCXJldHVybiBzLT5h
ZGRyOwotLSAKMi43LjQKCg==
--------------6AAF02DB08CAA2E0F2C8324B
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="4.9-0002-fork-unconditionally-clear-stack-on-fork.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="4.9-0002-fork-unconditionally-clear-stack-on-fork.patch"

RnJvbSA1MzcxY2QwYmIxZTJjYThkMTYwMzg0NWM3NjRlMTUyNGY3ZTcyOWFkIE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBLZWVzIENvb2sgPGtlZXNjb29rQGNocm9taXVtLm9y
Zz4KRGF0ZTogRnJpLCAyMCBBcHIgMjAxOCAxNDo1NTozMSAtMDcwMApTdWJqZWN0OiBbUEFU
Q0ggMi8yXSBmb3JrOiB1bmNvbmRpdGlvbmFsbHkgY2xlYXIgc3RhY2sgb24gZm9yawoKY29t
bWl0IGUwMWU4MDYzNGVjZGRlMWRkMTEzYWM0M2IzYWRhZDIxYjQ3ZjM5NTcgdXBzdHJlYW0u
CgpPbmUgb2YgdGhlIGNsYXNzZXMgb2Yga2VybmVsIHN0YWNrIGNvbnRlbnQgbGVha3NbMV0g
aXMgZXhwb3NpbmcgdGhlCmNvbnRlbnRzIG9mIHByaW9yIGhlYXAgb3Igc3RhY2sgY29udGVu
dHMgd2hlbiBhIG5ldyBwcm9jZXNzIHN0YWNrIGlzCmFsbG9jYXRlZC4gIE5vcm1hbGx5LCB0
aG9zZSBzdGFja3MgYXJlIG5vdCB6ZXJvZWQsIGFuZCB0aGUgb2xkIGNvbnRlbnRzCnJlbWFp
biBpbiBwbGFjZS4gIEluIHRoZSBmYWNlIG9mIHN0YWNrIGNvbnRlbnQgZXhwb3N1cmUgZmxh
d3MsIHRob3NlCmNvbnRlbnRzIGNhbiBsZWFrIHRvIHVzZXJzcGFjZS4KCkZpeGluZyB0aGlz
IHdpbGwgbWFrZSB0aGUga2VybmVsIG5vIGxvbmdlciB2dWxuZXJhYmxlIHRvIHRoZXNlIGZs
YXdzLCBhcwp0aGUgc3RhY2sgd2lsbCBiZSB3aXBlZCBlYWNoIHRpbWUgYSBzdGFjayBpcyBh
c3NpZ25lZCB0byBhIG5ldyBwcm9jZXNzLgpUaGVyZSdzIG5vdCBhIG1lYW5pbmdmdWwgY2hh
bmdlIGluIHJ1bnRpbWUgcGVyZm9ybWFuY2U7IGl0IGFsbW9zdCBsb29rcwpsaWtlIGl0IHBy
b3ZpZGVzIGEgYmVuZWZpdC4KClBlcmZvcm1pbmcgYmFjay10by1iYWNrIGtlcm5lbCBidWls
ZHMgYmVmb3JlOgoJUnVuIHRpbWVzOiAxNTcuODYgMTU3LjA5IDE1OC45MCAxNjAuOTQgMTYw
LjgwCglNZWFuOiAxNTkuMTIKCVN0ZCBEZXY6IDEuNTQKCmFuZCBhZnRlcjoKCVJ1biB0aW1l
czogMTU5LjMxIDE1Ny4zNCAxNTYuNzEgMTU4LjE1IDE2MC44MQoJTWVhbjogMTU4LjQ2CglT
dGQgRGV2OiAxLjQ2CgpJbnN0ZWFkIG9mIG1ha2luZyB0aGlzIGEgYnVpbGQgb3IgcnVudGlt
ZSBjb25maWcsIEFuZHkgTHV0b21pcnNraQpyZWNvbW1lbmRlZCB0aGlzIGp1c3QgYmUgZW5h
YmxlZCBieSBkZWZhdWx0LgoKWzFdIEEgbm9pc3kgc2VhcmNoIGZvciBtYW55IGtpbmRzIG9m
IHN0YWNrIGNvbnRlbnQgbGVha3MgY2FuIGJlIHNlZW4gaGVyZToKaHR0cHM6Ly9jdmUubWl0
cmUub3JnL2NnaS1iaW4vY3Zla2V5LmNnaT9rZXl3b3JkPWxpbnV4K2tlcm5lbCtzdGFjayts
ZWFrCgpJIGRpZCBzb21lIG1vcmUgd2l0aCBwZXJmIGFuZCBjeWNsZSBjb3VudHMgb24gcnVu
bmluZyAxMDAsMDAwIGV4ZWNzIG9mCi9iaW4vdHJ1ZS4KCmJlZm9yZToKQ3ljbGVzOiAyMTg4
NTg4NjE1NTEgMjE4ODUzMDM2MTMwIDIxNDcyNzYxMDk2OSAyMjc2NTY4NDQxMjIgMjI0OTgw
NTQyODQxCk1lYW46ICAyMjEwMTUzNzkxMjIuNjAKU3RkIERldjogNDY2MjQ4NjU1Mi40NwoK
YWZ0ZXI6CkN5Y2xlczogMjEzODY4OTQ1MDYwIDIxMzExOTI3NTIwNCAyMTE4MjAxNjk0NTYg
MjI0NDI2NjczMjU5IDIyNTQ4OTk4NjM0OApNZWFuOiAgMjE3NzQ1MDA5ODY1LjQwClN0ZCBE
ZXY6IDU5MzU1NTkyNzkuOTkKCkl0IGNvbnRpbnVlcyB0byBsb29rIGxpa2UgaXQncyBmYXN0
ZXIsIHRob3VnaCB0aGUgZGV2aWF0aW9uIGlzIHJhdGhlcgp3aWRlLCBidXQgSSdtIG5vdCBz
dXJlIHdoYXQgSSBjb3VsZCBkbyB0aGF0IHdvdWxkIGJlIGxlc3Mgbm9pc3kuICBJJ20Kb3Bl
biB0byBpZGVhcyEKCkxpbms6IGh0dHA6Ly9sa21sLmtlcm5lbC5vcmcvci8yMDE4MDIyMTAy
MTY1OS5HQTM3MDczQGJlYXN0ClNpZ25lZC1vZmYtYnk6IEtlZXMgQ29vayA8a2Vlc2Nvb2tA
Y2hyb21pdW0ub3JnPgpBY2tlZC1ieTogTWljaGFsIEhvY2tvIDxtaG9ja29Ac3VzZS5jb20+
ClJldmlld2VkLWJ5OiBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3Jn
PgpDYzogQW5keSBMdXRvbWlyc2tpIDxsdXRvQGtlcm5lbC5vcmc+CkNjOiBMYXVyYSBBYmJv
dHQgPGxhYmJvdHRAcmVkaGF0LmNvbT4KQ2M6IFJhc211cyBWaWxsZW1vZXMgPHJhc211cy52
aWxsZW1vZXNAcHJldmFzLmRrPgpDYzogTWVsIEdvcm1hbiA8bWdvcm1hbkB0ZWNoc2luZ3Vs
YXJpdHkubmV0PgpTaWduZWQtb2ZmLWJ5OiBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZv
dW5kYXRpb24ub3JnPgpTaWduZWQtb2ZmLWJ5OiBMaW51cyBUb3J2YWxkcyA8dG9ydmFsZHNA
bGludXgtZm91bmRhdGlvbi5vcmc+ClsgU3JpdmF0c2E6IEJhY2twb3J0ZWQgdG8gNC45Lnkg
XQpTaWduZWQtb2ZmLWJ5OiBTcml2YXRzYSBTLiBCaGF0IDxzcml2YXRzYUBjc2FpbC5taXQu
ZWR1PgpSZXZpZXdlZC1ieTogU3JpbmlkaGkgUmFvIDxzcmluaWRoaXJAdm13YXJlLmNvbT4K
LS0tCiBpbmNsdWRlL2xpbnV4L3RocmVhZF9pbmZvLmggfCA3ICstLS0tLS0KIGtlcm5lbC9m
b3JrLmMgICAgICAgICAgICAgICB8IDMgKy0tCiAyIGZpbGVzIGNoYW5nZWQsIDIgaW5zZXJ0
aW9ucygrKSwgOCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L3Ro
cmVhZF9pbmZvLmggYi9pbmNsdWRlL2xpbnV4L3RocmVhZF9pbmZvLmgKaW5kZXggY2Y4N2Mx
Ni4uNWU2NDM2NyAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC90aHJlYWRfaW5mby5oCisr
KyBiL2luY2x1ZGUvbGludXgvdGhyZWFkX2luZm8uaApAQCAtNTksMTIgKzU5LDcgQEAgZXh0
ZXJuIGxvbmcgZG9fbm9fcmVzdGFydF9zeXNjYWxsKHN0cnVjdCByZXN0YXJ0X2Jsb2NrICpw
YXJtKTsKIAogI2lmZGVmIF9fS0VSTkVMX18KIAotI2lmIElTX0VOQUJMRUQoQ09ORklHX0RF
QlVHX1NUQUNLX1VTQUdFKSB8fCBJU19FTkFCTEVEKENPTkZJR19ERUJVR19LTUVNTEVBSykK
LSMgZGVmaW5lIFRIUkVBRElORk9fR0ZQCQkoR0ZQX0tFUk5FTF9BQ0NPVU5UIHwgX19HRlBf
Tk9UUkFDSyB8IFwKLQkJCQkgX19HRlBfWkVSTykKLSNlbHNlCi0jIGRlZmluZSBUSFJFQURJ
TkZPX0dGUAkJKEdGUF9LRVJORUxfQUNDT1VOVCB8IF9fR0ZQX05PVFJBQ0spCi0jZW5kaWYK
KyNkZWZpbmUgVEhSRUFESU5GT19HRlAJKEdGUF9LRVJORUxfQUNDT1VOVCB8IF9fR0ZQX05P
VFJBQ0sgfCBfX0dGUF9aRVJPKQogCiAvKgogICogZmxhZyBzZXQvY2xlYXIvdGVzdCB3cmFw
cGVycwpkaWZmIC0tZ2l0IGEva2VybmVsL2ZvcmsuYyBiL2tlcm5lbC9mb3JrLmMKaW5kZXgg
YzE5ZTZkNC4uMmM5OGI5OCAxMDA2NDQKLS0tIGEva2VybmVsL2ZvcmsuYworKysgYi9rZXJu
ZWwvZm9yay5jCkBAIC0xODQsMTAgKzE4NCw5IEBAIHN0YXRpYyB1bnNpZ25lZCBsb25nICph
bGxvY190aHJlYWRfc3RhY2tfbm9kZShzdHJ1Y3QgdGFza19zdHJ1Y3QgKnRzaywgaW50IG5v
ZGUpCiAJCQljb250aW51ZTsKIAkJdGhpc19jcHVfd3JpdGUoY2FjaGVkX3N0YWNrc1tpXSwg
TlVMTCk7CiAKLSNpZmRlZiBDT05GSUdfREVCVUdfS01FTUxFQUsKIAkJLyogQ2xlYXIgc3Rh
bGUgcG9pbnRlcnMgZnJvbSByZXVzZWQgc3RhY2suICovCiAJCW1lbXNldChzLT5hZGRyLCAw
LCBUSFJFQURfU0laRSk7Ci0jZW5kaWYKKwogCQl0c2stPnN0YWNrX3ZtX2FyZWEgPSBzOwog
CQlsb2NhbF9pcnFfZW5hYmxlKCk7CiAJCXJldHVybiBzLT5hZGRyOwotLSAKMi43LjQKCg==
--------------6AAF02DB08CAA2E0F2C8324B--
