Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C19CC6B000D
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:40:01 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id be11-v6so15654349plb.2
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:40:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 185-v6si22258159pfa.199.2018.10.17.15.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 15:40:00 -0700 (PDT)
Subject: Re: [PATCH v5 03/27] x86/fpu/xstate: Introduce XSAVES system states
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-4-yu-cheng.yu@intel.com>
 <20181017104137.GE22535@zn.tnic>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <32da559b-7958-60db-e328-f0eb316e668e@infradead.org>
Date: Wed, 17 Oct 2018 15:39:47 -0700
MIME-Version: 1.0
In-Reply-To: <20181017104137.GE22535@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 10/17/18 3:41 AM, Borislav Petkov wrote:

>> @@ -702,6 +703,7 @@ static int init_xstate_size(void)
>>   */
>>  static void fpu__init_disable_system_xstate(void)
>>  {
>> +	xfeatures_mask_all = 0;
>>  	xfeatures_mask_user = 0;
>>  	cr4_clear_bits(X86_CR4_OSXSAVE);
>>  	fpu__xstate_clear_all_cpu_caps();
>> @@ -717,6 +719,8 @@ void __init fpu__init_system_xstate(void)
>>  	static int on_boot_cpu __initdata = 1;
>>  	int err;
>>  	int i;
>> +	u64 cpu_user_xfeatures_mask;
>> +	u64 cpu_system_xfeatures_mask;
> 
> Please sort function local variables declaration in a reverse christmas
> tree order:
> 
> 	<type> longest_variable_name;
> 	<type> shorter_var_name;
> 	<type> even_shorter;
> 	<type> i;

Hi,

Would you mind explaining this request? (requirement?)
Other than to say that it is the preference of some maintainers,
please say Why it is preferred.

and since the <type>s above won't typically be the same length,
it's not for variable name alignment, right?

thanks,
-- 
~Randy
