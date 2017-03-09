Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 716F06B0426
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 18:18:59 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id o126so136572520pfb.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 15:18:59 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id x5si1089217pgj.207.2017.03.09.15.18.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 15:18:58 -0800 (PST)
Subject: Re: [Xen-devel] [PATCH v5 2/3] x86: Remap GDT tables in the Fixmap
 section
References: <20170306220348.79702-1-thgarnie@google.com>
 <20170306220348.79702-2-thgarnie@google.com>
 <CALCETrVXHc-EAhBtdhL9FXSW1G2VbohRY4UJuOtpRG1K0Q-Ogg@mail.gmail.com>
 <17ffcc5b-1c9a-51b6-272a-5eaecf1bc0c4@citrix.com>
 <CALCETrWv-u7OdjWDY+5eF7p-ngPun-yYf0QegMzYc6MGVQd-4w@mail.gmail.com>
 <CAJcbSZExVWA0jvAoxLLc+58Ag9cHchifrHP=fFfzU_onHo2PyA@mail.gmail.com>
 <5cf31779-45c5-d37f-86bc-d5afb3fb7ab6@oracle.com>
 <51c23e92-d1f0-427f-e069-c92fc4ed6226@oracle.com>
 <CAJcbSZEnUBfLHjf+bHqY0JQhQXD9urX45BXrQjx=1=A5gPpp_w@mail.gmail.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <36579cc4-05e7-a448-767c-b9ad940362fc@oracle.com>
Date: Thu, 9 Mar 2017 18:17:18 -0500
MIME-Version: 1.0
In-Reply-To: <CAJcbSZEnUBfLHjf+bHqY0JQhQXD9urX45BXrQjx=1=A5gPpp_w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Michal Hocko <mhocko@suse.com>, Stanislaw Gruszka <sgruszka@redhat.com>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Frederic Weisbecker <fweisbec@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Chris Wilson <chris@chris-wilson.co.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Alexander Potapenko <glider@google.com>, Pavel Machek <pavel@ucw.cz>, "H . Peter Anvin" <hpa@zytor.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Jiri Olsa <jolsa@redhat.com>, zijun_hu <zijun_hu@htc.com>, Prarit Bhargava <prarit@redhat.com>, Andi Kleen <ak@linux.intel.com>, Len Brown <len.brown@intel.com>, Jonathan Corbet <corbet@lwn.net>, Michael Ellerman <mpe@ellerman.id.au>, Joerg Roedel <joro@8bytes.org>, X86 ML <x86@kernel.org>, "Luis R . Rodriguez" <mcgrof@kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Ingo Molnar <mingo@redhat.com>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, Borislav Petkov <bp@suse.de>, Fenghua Yu <fenghua.yu@intel.com>, Jiri Kosina <jikos@kernel.org>, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, He Chen <he.chen@linux.intel.com>, Brian Gerst <brgerst@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, lguest@lists.ozlabs.org, Andy Lutomirski <luto@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Cooper <andrew.cooper3@citrix.com>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Paolo Bonzini <pbonzini@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>

On 03/09/2017 05:31 PM, Thomas Garnier wrote:
> On Thu, Mar 9, 2017 at 2:13 PM, Boris Ostrovsky
> <boris.ostrovsky@oracle.com> wrote:
>>>> I don't have any experience with Xen so it would be great if virtme can test it.
>>> I am pretty sure I tested this series at some point but I'll test it again.
>>>
>>
>> Fails 32-bit build:
>>
>>
>> /home/build/linux-boris/arch/x86/kvm/vmx.c: In function a??segment_basea??:
>> /home/build/linux-boris/arch/x86/kvm/vmx.c:2054: error: a??host_gdta??
>> undeclared (first use in this function)
>> /home/build/linux-boris/arch/x86/kvm/vmx.c:2054: error: (Each undeclared
>> identifier is reported only once
>> /home/build/linux-boris/arch/x86/kvm/vmx.c:2054: error: for each
>> function it appears in.)
>> /home/build/linux-boris/arch/x86/kvm/vmx.c:2054: error: type defaults to
>> a??inta?? in declaration of a??type namea??
>> /home/build/linux-boris/arch/x86/kvm/vmx.c:2054: error: type defaults to
>> a??inta?? in declaration of a??type namea??
>> /home/build/linux-boris/arch/x86/kvm/vmx.c:2054: warning: initialization
>> from incompatible pointer type
>> /home/build/linux-boris/arch/x86/kvm/vmx.c:2054: warning: unused
>> variable a??gdta??
>>
>>
>> -boris
> It seems that I forgot to remove line 2054 on the rebase. My 32-bit
> build comes clean but I assume it is not good enough compare to the
> full version I build for 64-bit KVM testing.
>
> Remove just this line and it should build fine, I will fix this on the
> next iteration.
>
> Thanks for testing,
>


So this, in fact, does break Xen in that the hypercall to set GDT fails.

I will have lo look at this tomorrow but I definitely at least built
with v3 of this series. And I don't see why I wouldn't have tested it
once I built it.

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
