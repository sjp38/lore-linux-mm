Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBF486B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 15:09:02 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a70-v6so17600811qkb.16
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 12:09:02 -0700 (PDT)
Received: from outgoing-stata.csail.mit.edu (outgoing-stata.csail.mit.edu. [128.30.2.210])
        by mx.google.com with ESMTP id z4-v6si1749761qkl.297.2018.08.07.12.08.54
        for <linux-mm@kvack.org>;
        Tue, 07 Aug 2018 12:08:54 -0700 (PDT)
Subject: Re: [RESEND] Spectre-v2 (IBPB/IBRS) and SSBD fixes for 4.4.y
References: <153156030832.10043.13438231886571087086.stgit@srivatsa-ubuntu>
 <nycvar.YFH.7.76.1807232357440.997@cbobk.fhfr.pm>
 <e57d5ac9-68d7-8ccf-6117-5a2f9d9e1112@csail.mit.edu>
 <nycvar.YFH.7.76.1807242351500.997@cbobk.fhfr.pm>
 <CAGXu5jJvTF0KXs+3J32u5v1Ba5gZd0Umgib6D6++ie+LzqnuWA@mail.gmail.com>
 <c616c38b-52cc-2f88-7ea3-00f3a572255a@csail.mit.edu>
 <CAGXu5j+Y5TNBY1WCz=4E8B5nFo2jzyswg6iaQja_92GZB+hE0w@mail.gmail.com>
 <8a87a705-97c0-eb3d-8878-8ffe052f065d@csail.mit.edu>
 <20180807134934.GA16837@kroah.com>
From: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Message-ID: <824c77d3-93d8-fb90-6eb0-afa4aeef6644@csail.mit.edu>
Date: Tue, 7 Aug 2018 12:08:07 -0700
MIME-Version: 1.0
In-Reply-To: <20180807134934.GA16837@kroah.com>
Content-Type: multipart/mixed;
 boundary="------------8D3BCDF7813D9258CC70DFBD"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Kees Cook <keescook@chromium.org>, Jiri Kosina <jikos@kernel.org>, "# 3.4.x" <stable@vger.kernel.org>, Denys Vlasenko <dvlasenk@redhat.com>, Bo Gan <ganb@vmware.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Andi Kleen <ak@linux.intel.com>, linux-tip-commits@vger.kernel.org, Jia Zhang <qianyue.zj@alibaba-inc.com>, Josh Poimboeuf <jpoimboe@redhat.com>, xen-devel <xen-devel@lists.xenproject.org>, =?UTF-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@amacapital.net>, Arnaldo Carvalho de Melo <acme@redhat.com>, Sherry Hurwitz <sherry.hurwitz@amd.com>, LKML <linux-kernel@vger.kernel.org>, Shuah Khan <shuahkh@osg.samsung.com>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, KarimAllah Ahmed <karahmed@amazon.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Joerg Roedel <joro@8bytes.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Kyle Huey <me@kylehuey.com>, Will Drewry <wad@chromium.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Brian Gerst <brgerst@gmail.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Thomas Garnier <thgarnie@google.com>, Andrew Morton <akpm@linux-foundation.org>, Joe Konno <joe.konno@linux.intel.com>, kvm <kvm@vger.kernel.org>, Piotr Luc <piotr.luc@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Jan Beulich <jbeulich@suse.com>, Arjan van de Ven <arjan@linux.intel.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, Juergen Gross <jgross@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?Q?J=c3=b6rg_Otte?= <jrg.otte@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alexander Sergeyev <sergeev917@gmail.com>, Josh Triplett <josh@joshtriplett.org>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Tony Luck <tony.luck@intel.com>, Laura Abbott <labbott@fedoraproject.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexey Makhalov <amakhalov@vmware.com>, Dave Hansen <dave@sr71.net>, ashok.raj@intel.com, Mel Gorman <mgorman@suse.de>, =?UTF-8?B?TWlja2HDq2xTYWxhw7xu?= <mic@digikod.net>, Fenghua Yu <fenghua.yu@intel.com>, "Matt Helsley (VMware)" <matt.helsley@gmail.com>, Vince Weaver <vincent.weaver@maine.edu>, Prarit Bhargava <prarit@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Dan Williams <dan.j.williams@intel.com>, Jim Mattson <jmattson@google.com>, Dave Young <dyoung@redhat.com>, linux-edac <linux-edac@vger.kernel.org>, Jon Masters <jcm@redhat.com>, Andy Lutomirski <luto@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Linux-MM <linux-mm@kvack.org>, Jiri Olsa <jolsa@redhat.com>, "Van De Ven, Arjan" <arjan.van.de.ven@intel.com>, sironi@amazon.de, Frederic Weisbecker <fweisbec@gmail.com>, Kyle Huey <khuey@kylehuey.com>, Alexander Popov <alpopov@ptsecurity.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Nadav Amit <nadav.amit@gmail.com>, Yazen Ghannam <Yazen.Ghannam@amd.com>, Wanpeng Li <kernellwp@gmail.com>, Stephane Eranian <eranian@google.com>, David Woodhouse <dwmw2@infradead.org>, srivatsab@vmware.com, srinidhir@vmware.com, khlebnikov@yandex-team.ru, catalin.marinas@arm.com

This is a multi-part message in MIME format.
--------------8D3BCDF7813D9258CC70DFBD
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 8/7/18 6:49 AM, Greg KH wrote:
> On Fri, Aug 03, 2018 at 04:20:31PM -0700, Srivatsa S. Bhat wrote:
>> On 8/2/18 3:22 PM, Kees Cook wrote:
>>> On Thu, Aug 2, 2018 at 12:22 PM, Srivatsa S. Bhat
>>> <srivatsa@csail.mit.edu> wrote:
>>>> On 7/26/18 4:09 PM, Kees Cook wrote:
>>>>> On Tue, Jul 24, 2018 at 3:02 PM, Jiri Kosina <jikos@kernel.org> wrote:
>>>>>> On Tue, 24 Jul 2018, Srivatsa S. Bhat wrote:
>>>>>>
>>>>>>> However, if you are proposing that you'd like to contribute the enhanced
>>>>>>> PTI/Spectre (upstream) patches from the SLES 4.4 tree to 4.4 stable, and
>>>>>>> have them merged instead of this patch series, then I would certainly
>>>>>>> welcome it!
>>>>>>
>>>>>> I'd in principle love us to push everything back to 4.4, but there are a
>>>>>> few reasons (*) why that's not happening shortly.
>>>>>>
>>>>>> Anyway, to point out explicitly what's really needed for those folks
>>>>>> running 4.4-stable and relying on PTI providing The Real Thing(TM), it's
>>>>>> either a 4.4-stable port of
>>>>>>
>>>>>>         http://kernel.suse.com/cgit/kernel-source/plain/patches.suse/x86-entry-64-use-a-per-cpu-trampoline-stack.patch?id=3428a77b02b1ba03e45d8fc352ec350429f57fc7
>>>>>>
>>>>>> or making THREADINFO_GFP imply __GFP_ZERO.
>>>>>
>>>>> This is true in Linus's tree now. Should be trivial to backport:
>>>>> https://git.kernel.org/linus/e01e80634ecdd
>>>>>
>>>>
>>>> Hi Jiri, Kees,
>>>>
>>>> Thank you for suggesting the patch! I have attached the (locally
>>>> tested) 4.4 and 4.9 backports of that patch with this mail. (The
>>>> mainline commit applies cleanly on 4.14).
>>>>
>>>> Greg, could you please consider including them in stable 4.4, 4.9
>>>> and 4.14?
>>>
>>> I don't think your v4.9 is sufficient: it leaves the vmapped stack
>>> uncleared. v4.9 needs ca182551857 ("kmemleak: clear stale pointers
>>> from task stacks") included in the backport (really, just adding the
>>> memset()).
>>>
>>
>> Ah, I see, thank you! I have attached the updated patchset for 4.9
>> with this mail.
>>
>>> Otherwise, yup, looks good.
>>>
>> Thank you for reviewing the patches!
>>  
>> Regards,
>> Srivatsa
>> VMware Photon OS
> 
> These work for 4.9, do you also have a set for 4.4?
> 

Thank you for considering these patches for 4.9!

The (single) patch for 4.4 did not need any more changes, and hence is
the same as the one I attached in my previous mail. I'll attach it
again here for your reference.

Also, upstream commit e01e80634ecdde1 (fork: unconditionally clear
stack on fork) applies cleanly on 4.14 stable, so it would be great to
cherry-pick it to 4.14 stable as well.

Thank you!

Regards,
Srivatsa
VMware Photon OS

--------------8D3BCDF7813D9258CC70DFBD
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="4.4-fork-unconditionally-clear-stack-on-fork.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="4.4-fork-unconditionally-clear-stack-on-fork.patch"

RnJvbSA3ZTM5ZDhjY2JiMDg4OWMwM2NlNmRjMGRlZTBlNjNkNzhmMzdkMGE5IE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBLZWVzIENvb2sgPGtlZXNjb29rQGNocm9taXVtLm9y
Zz4KRGF0ZTogRnJpLCAyMCBBcHIgMjAxOCAxNDo1NTozMSAtMDcwMApTdWJqZWN0OiBbUEFU
Q0hdIGZvcms6IHVuY29uZGl0aW9uYWxseSBjbGVhciBzdGFjayBvbiBmb3JrCgpjb21taXQg
ZTAxZTgwNjM0ZWNkZGUxZGQxMTNhYzQzYjNhZGFkMjFiNDdmMzk1NyB1cHN0cmVhbS4KCk9u
ZSBvZiB0aGUgY2xhc3NlcyBvZiBrZXJuZWwgc3RhY2sgY29udGVudCBsZWFrc1sxXSBpcyBl
eHBvc2luZyB0aGUKY29udGVudHMgb2YgcHJpb3IgaGVhcCBvciBzdGFjayBjb250ZW50cyB3
aGVuIGEgbmV3IHByb2Nlc3Mgc3RhY2sgaXMKYWxsb2NhdGVkLiAgTm9ybWFsbHksIHRob3Nl
IHN0YWNrcyBhcmUgbm90IHplcm9lZCwgYW5kIHRoZSBvbGQgY29udGVudHMKcmVtYWluIGlu
IHBsYWNlLiAgSW4gdGhlIGZhY2Ugb2Ygc3RhY2sgY29udGVudCBleHBvc3VyZSBmbGF3cywg
dGhvc2UKY29udGVudHMgY2FuIGxlYWsgdG8gdXNlcnNwYWNlLgoKRml4aW5nIHRoaXMgd2ls
bCBtYWtlIHRoZSBrZXJuZWwgbm8gbG9uZ2VyIHZ1bG5lcmFibGUgdG8gdGhlc2UgZmxhd3Ms
IGFzCnRoZSBzdGFjayB3aWxsIGJlIHdpcGVkIGVhY2ggdGltZSBhIHN0YWNrIGlzIGFzc2ln
bmVkIHRvIGEgbmV3IHByb2Nlc3MuClRoZXJlJ3Mgbm90IGEgbWVhbmluZ2Z1bCBjaGFuZ2Ug
aW4gcnVudGltZSBwZXJmb3JtYW5jZTsgaXQgYWxtb3N0IGxvb2tzCmxpa2UgaXQgcHJvdmlk
ZXMgYSBiZW5lZml0LgoKUGVyZm9ybWluZyBiYWNrLXRvLWJhY2sga2VybmVsIGJ1aWxkcyBi
ZWZvcmU6CglSdW4gdGltZXM6IDE1Ny44NiAxNTcuMDkgMTU4LjkwIDE2MC45NCAxNjAuODAK
CU1lYW46IDE1OS4xMgoJU3RkIERldjogMS41NAoKYW5kIGFmdGVyOgoJUnVuIHRpbWVzOiAx
NTkuMzEgMTU3LjM0IDE1Ni43MSAxNTguMTUgMTYwLjgxCglNZWFuOiAxNTguNDYKCVN0ZCBE
ZXY6IDEuNDYKCkluc3RlYWQgb2YgbWFraW5nIHRoaXMgYSBidWlsZCBvciBydW50aW1lIGNv
bmZpZywgQW5keSBMdXRvbWlyc2tpCnJlY29tbWVuZGVkIHRoaXMganVzdCBiZSBlbmFibGVk
IGJ5IGRlZmF1bHQuCgpbMV0gQSBub2lzeSBzZWFyY2ggZm9yIG1hbnkga2luZHMgb2Ygc3Rh
Y2sgY29udGVudCBsZWFrcyBjYW4gYmUgc2VlbiBoZXJlOgpodHRwczovL2N2ZS5taXRyZS5v
cmcvY2dpLWJpbi9jdmVrZXkuY2dpP2tleXdvcmQ9bGludXgra2VybmVsK3N0YWNrK2xlYWsK
CkkgZGlkIHNvbWUgbW9yZSB3aXRoIHBlcmYgYW5kIGN5Y2xlIGNvdW50cyBvbiBydW5uaW5n
IDEwMCwwMDAgZXhlY3Mgb2YKL2Jpbi90cnVlLgoKYmVmb3JlOgpDeWNsZXM6IDIxODg1ODg2
MTU1MSAyMTg4NTMwMzYxMzAgMjE0NzI3NjEwOTY5IDIyNzY1Njg0NDEyMiAyMjQ5ODA1NDI4
NDEKTWVhbjogIDIyMTAxNTM3OTEyMi42MApTdGQgRGV2OiA0NjYyNDg2NTUyLjQ3CgphZnRl
cjoKQ3ljbGVzOiAyMTM4Njg5NDUwNjAgMjEzMTE5Mjc1MjA0IDIxMTgyMDE2OTQ1NiAyMjQ0
MjY2NzMyNTkgMjI1NDg5OTg2MzQ4Ck1lYW46ICAyMTc3NDUwMDk4NjUuNDAKU3RkIERldjog
NTkzNTU1OTI3OS45OQoKSXQgY29udGludWVzIHRvIGxvb2sgbGlrZSBpdCdzIGZhc3Rlciwg
dGhvdWdoIHRoZSBkZXZpYXRpb24gaXMgcmF0aGVyCndpZGUsIGJ1dCBJJ20gbm90IHN1cmUg
d2hhdCBJIGNvdWxkIGRvIHRoYXQgd291bGQgYmUgbGVzcyBub2lzeS4gIEknbQpvcGVuIHRv
IGlkZWFzIQoKTGluazogaHR0cDovL2xrbWwua2VybmVsLm9yZy9yLzIwMTgwMjIxMDIxNjU5
LkdBMzcwNzNAYmVhc3QKU2lnbmVkLW9mZi1ieTogS2VlcyBDb29rIDxrZWVzY29va0BjaHJv
bWl1bS5vcmc+CkFja2VkLWJ5OiBNaWNoYWwgSG9ja28gPG1ob2Nrb0BzdXNlLmNvbT4KUmV2
aWV3ZWQtYnk6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+CkNj
OiBBbmR5IEx1dG9taXJza2kgPGx1dG9Aa2VybmVsLm9yZz4KQ2M6IExhdXJhIEFiYm90dCA8
bGFiYm90dEByZWRoYXQuY29tPgpDYzogUmFzbXVzIFZpbGxlbW9lcyA8cmFzbXVzLnZpbGxl
bW9lc0BwcmV2YXMuZGs+CkNjOiBNZWwgR29ybWFuIDxtZ29ybWFuQHRlY2hzaW5ndWxhcml0
eS5uZXQ+ClNpZ25lZC1vZmYtYnk6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRh
dGlvbi5vcmc+ClNpZ25lZC1vZmYtYnk6IExpbnVzIFRvcnZhbGRzIDx0b3J2YWxkc0BsaW51
eC1mb3VuZGF0aW9uLm9yZz4KWyBTcml2YXRzYTogQmFja3BvcnRlZCB0byA0LjQueSBdClNp
Z25lZC1vZmYtYnk6IFNyaXZhdHNhIFMuIEJoYXQgPHNyaXZhdHNhQGNzYWlsLm1pdC5lZHU+
ClJldmlld2VkLWJ5OiBTcmluaWRoaSBSYW8gPHNyaW5pZGhpckB2bXdhcmUuY29tPgotLS0K
IGluY2x1ZGUvbGludXgvdGhyZWFkX2luZm8uaCB8IDYgKy0tLS0tCiAxIGZpbGUgY2hhbmdl
ZCwgMSBpbnNlcnRpb24oKyksIDUgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvaW5jbHVk
ZS9saW51eC90aHJlYWRfaW5mby5oIGIvaW5jbHVkZS9saW51eC90aHJlYWRfaW5mby5oCmlu
ZGV4IGZmMzA3YjUuLjY0Njg5MWYgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvdGhyZWFk
X2luZm8uaAorKysgYi9pbmNsdWRlL2xpbnV4L3RocmVhZF9pbmZvLmgKQEAgLTU1LDExICs1
NSw3IEBAIGV4dGVybiBsb25nIGRvX25vX3Jlc3RhcnRfc3lzY2FsbChzdHJ1Y3QgcmVzdGFy
dF9ibG9jayAqcGFybSk7CiAKICNpZmRlZiBfX0tFUk5FTF9fCiAKLSNpZmRlZiBDT05GSUdf
REVCVUdfU1RBQ0tfVVNBR0UKLSMgZGVmaW5lIFRIUkVBRElORk9fR0ZQCQkoR0ZQX0tFUk5F
TCB8IF9fR0ZQX05PVFJBQ0sgfCBfX0dGUF9aRVJPKQotI2Vsc2UKLSMgZGVmaW5lIFRIUkVB
RElORk9fR0ZQCQkoR0ZQX0tFUk5FTCB8IF9fR0ZQX05PVFJBQ0spCi0jZW5kaWYKKyNkZWZp
bmUgVEhSRUFESU5GT19HRlAJCShHRlBfS0VSTkVMIHwgX19HRlBfTk9UUkFDSyB8IF9fR0ZQ
X1pFUk8pCiAKIC8qCiAgKiBmbGFnIHNldC9jbGVhci90ZXN0IHdyYXBwZXJzCi0tIAoyLjcu
NAoK
--------------8D3BCDF7813D9258CC70DFBD--
