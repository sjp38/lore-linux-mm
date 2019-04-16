Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C8C5C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:45:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1178E20880
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:45:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=efficios.com header.i=@efficios.com header.b="qhLXc+JX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1178E20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=efficios.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9ED116B0003; Tue, 16 Apr 2019 15:45:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99CF06B0006; Tue, 16 Apr 2019 15:45:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 863496B0007; Tue, 16 Apr 2019 15:45:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 644406B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 15:45:30 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id o34so20442669qte.5
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:45:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:date:from:to:cc
         :message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=+KtXHDVIW5ZnvdFUX7jsSXY+Tsxke5FypxGaUIdjB+w=;
        b=EdJUimXB7EsjR1wkyDE4RLqe1Vni/uO/SeIQQcznHnge7Gif1+UGy/N7DVd7GJqa5L
         9HBDg40zSoXBFSVVQJF2tAWhbJugx9qBNKCENqhJdzDas9Qt5WgFedqleyPqJ80QU5Uc
         e4ts+F8X6XTqmxmtAzzFlZ0TjURqtBOW0lOztw6wIXcy8a+VkGDdqtGkQ8agcCp+gT3s
         tYED5X8EMrvj1C3jr9K6X+P5pqQAhI8Sa6peEs6E3W8qj+ugFd4vHKNqvrwQOWF57iQH
         Iay7dBjk7l3Y1qHITAlBpdnytNYDwX4yByADpuiK1SFHp8q1Am98FH1HhQlDLY7vm6FX
         cAkw==
X-Gm-Message-State: APjAAAUjr+JSK3ntw4sIwws6eLhQBvFPi+8eUqg0+VAS+WeVBLoRehd6
	TzXvm/Mvf5KFJ9yAiJwItrqRDy26/z8iSNGtO5a4oAzpv+npcmnu4VMJo9KMFW/QnYMHL4KM2BY
	1PSwU5KzFyBY8Vmn0/J56dbts6s/z3Bl28mKvwmbZDu5kD+KYjjBiqckCPBShbDOMYQ==
X-Received: by 2002:a0c:e2d4:: with SMTP id t20mr6539555qvl.102.1555443930084;
        Tue, 16 Apr 2019 12:45:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5HSdWnLCFuZSKZAKfvCMj8nGklBbiUti+rWb2qCMAwpB+EaGG2Ejh2Cg8lNkB2nGhOcEm
X-Received: by 2002:a0c:e2d4:: with SMTP id t20mr6539450qvl.102.1555443929056;
        Tue, 16 Apr 2019 12:45:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555443929; cv=none;
        d=google.com; s=arc-20160816;
        b=P2zl6HmrW6YdrnpQ1Q+wWqwLmrj6mKQluerFHUVMuwiYV+MVF5E8n9kvGuTSEkomzT
         qXw1PLuTYVz4J+Z3Mpa0l5EGQ9l21iA29VRM+DVsr/6bCwN2wAReaxeAJbsIZsQpJztf
         H6KeHFakba+NkCkix0SdPT0neaxZNKAzryLxoZxAeNUnGT5qFy4XNiQqmiJEZPx68OxU
         mYSgoGeGwtflxb0CLOpACzDTmKg1vLT7Bt3aQtEwWUqeP0+r/aIpZPQzeavWyGUK1RKV
         7Y1M3qC+LXn3IDheiJabl/CVFpCNbD2sXuCL2UqFQHZjjEQWFqEdUevDiMD8H0Dzhc5u
         9LGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date
         :dkim-signature:dkim-filter;
        bh=+KtXHDVIW5ZnvdFUX7jsSXY+Tsxke5FypxGaUIdjB+w=;
        b=oo8ZssiCCPnB9SQdQ+NQKI6psRwY1z1LndOHGgHQ/QeOlBRLMBwognKfWuT7CqeO61
         WD8UyDJYz3b+Mxd/f5CHgygZY6hr1rgTqaid5X12C5WO3vxUj6vNq6rLnMWewgzCG9WY
         VyvdkS+7vH0qvJozYk+g61d6Bt4PsiRnLCIzjAlrEpW1SQ6DI9pRFrM4X5kOUz8ShvUK
         CJRWfwwIE4cfu8Wfe7MNyHw9iybGrLBCPns7BK8sfyxVkVobH+z9x5OPlOiqChn6M8br
         jHa0WqQPXNUz0OaCiVO8eb/cF87HrVxDX2DmVFdKaYv568X5O4NUDZOiAwSsfSuCOiz+
         u+zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@efficios.com header.s=default header.b=qhLXc+JX;
       spf=pass (google.com: domain of compudj@efficios.com designates 2607:5300:60:7898::beef as permitted sender) smtp.mailfrom=compudj@efficios.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=efficios.com
Received: from mail.efficios.com (mail.efficios.com. [2607:5300:60:7898::beef])
        by mx.google.com with ESMTPS id x30si3785159qvf.161.2019.04.16.12.45.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 12:45:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of compudj@efficios.com designates 2607:5300:60:7898::beef as permitted sender) client-ip=2607:5300:60:7898::beef;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@efficios.com header.s=default header.b=qhLXc+JX;
       spf=pass (google.com: domain of compudj@efficios.com designates 2607:5300:60:7898::beef as permitted sender) smtp.mailfrom=compudj@efficios.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=efficios.com
Received: from localhost (ip6-localhost [IPv6:::1])
	by mail.efficios.com (Postfix) with ESMTP id 531891D69A6;
	Tue, 16 Apr 2019 15:45:28 -0400 (EDT)
Received: from mail.efficios.com ([IPv6:::1])
	by localhost (mail02.efficios.com [IPv6:::1]) (amavisd-new, port 10032)
	with ESMTP id zMieHQ82ZKVg; Tue, 16 Apr 2019 15:45:27 -0400 (EDT)
Received: from localhost (ip6-localhost [IPv6:::1])
	by mail.efficios.com (Postfix) with ESMTP id A152D1D699C;
	Tue, 16 Apr 2019 15:45:27 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.10.3 mail.efficios.com A152D1D699C
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=efficios.com;
	s=default; t=1555443927;
	bh=+KtXHDVIW5ZnvdFUX7jsSXY+Tsxke5FypxGaUIdjB+w=;
	h=Date:From:To:Message-ID:MIME-Version;
	b=qhLXc+JXcKC+jTBOCxXEmcdbArLuSHJ6RbO09PxrnBFtCacEr26sshYGIi2m/vNpj
	 3lwC7G3V0rcQ5DHWpKXDdGKTQZpWq4awc5/GqoARAGxSxHJouQHAFGOCKgu765cazk
	 du0RlziJwufBTJ0qHIBq5hIYku8AAxZbtZ76y6cvy46Zd6N/wS6dGU3Bio9eoA3qji
	 8e8bCKeQNeVT68FJx8VUX9nGyqy1cO0shJNQge3GMXnjiIJw15Na0XxudSiS8UyGE3
	 e+5lcDziyWSTtgr78xBiYaQzQibSF926bN1eIsNeh+uT2beaf5CU0fJHYqcSHwBoF/
	 xwYiUzKheY9bA==
X-Virus-Scanned: amavisd-new at efficios.com
Received: from mail.efficios.com ([IPv6:::1])
	by localhost (mail02.efficios.com [IPv6:::1]) (amavisd-new, port 10026)
	with ESMTP id LhXW8fOS8on1; Tue, 16 Apr 2019 15:45:27 -0400 (EDT)
Received: from mail02.efficios.com (mail02.efficios.com [167.114.142.138])
	by mail.efficios.com (Postfix) with ESMTP id 71A591D6995;
	Tue, 16 Apr 2019 15:45:27 -0400 (EDT)
Date: Tue, 16 Apr 2019 15:45:27 -0400 (EDT)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Guenter Roeck <groeck@google.com>, Kees Cook <keescook@chromium.org>, 
	kernelci <kernelci@groups.io>, 
	Guillaume Tucker <guillaume.tucker@collabora.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Mark Brown <broonie@kernel.org>, 
	Tomeu Vizoso <tomeu.vizoso@collabora.com>, 
	Matt Hart <matthew.hart@linaro.org>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, 
	Kevin Hilman <khilman@baylibre.com>, 
	Enric Balletbo i Serra <enric.balletbo@collabora.com>, 
	Nicholas Piggin <npiggin@gmail.com>, 
	linux <linux@dominikbrodowski.net>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, 
	Adrian Reber <adrian@lisas.de>, 
	linux-kernel <linux-kernel@vger.kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, 
	Richard Guy Briggs <rgb@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, info <info@kernelci.org>, 
	rostedt <rostedt@goodmis.org>, Jason Baron <jbaron@redhat.com>, 
	Rabin Vincent <rabin@rab.in>, 
	Russell King <rmk+kernel@arm.linux.org.uk>
Message-ID: <436115883.2781.1555443927341.JavaMail.zimbra@efficios.com>
In-Reply-To: <2030770457.2767.1555442711654.JavaMail.zimbra@efficios.com>
References: <20190215185151.GG7897@sirena.org.uk> <CAGXu5j+Sw2FyMc8L+8hTpEKbOsySFGrCmFtVP5gt9y2pJhYVUw@mail.gmail.com> <CABXOdTcXWf9iReoocaj9rZ7z17zt-62iPDuvQQSrQRtMeeZNiA@mail.gmail.com> <CAPcyv4i8xhA6B5e=YBq2Z5kooyUpYZ8Bv9qov-mvqm4Uz=KLWQ@mail.gmail.com> <CABXOdTc5=J7ZFgbiwahVind-SNt7+G_-TVO=v-Y5SBVPLdUFog@mail.gmail.com> <CAPcyv4gxk9xbsP3YSKzxu5Yp9FTefyxHc6xC33GwZ3Zf9_eeKA@mail.gmail.com> <1444448267.2739.1555442221738.JavaMail.zimbra@efficios.com> <2030770457.2767.1555442711654.JavaMail.zimbra@efficios.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [167.114.142.138]
X-Mailer: Zimbra 8.8.12_GA_3794 (ZimbraWebClient - FF66 (Linux)/8.8.12_GA_3794)
Thread-Topic: next/master boot bisection: next-20190215 on beaglebone-black
Thread-Index: o2XfqTzgA9kPUT1d7tzJPHm/yG+fqP8/3aj6mt0b2iM=
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

----- On Apr 16, 2019, at 3:25 PM, Mathieu Desnoyers mathieu.desnoyers@efficios.com wrote:

> ----- On Apr 16, 2019, at 3:17 PM, Mathieu Desnoyers
> mathieu.desnoyers@efficios.com wrote:
> 
>> ----- On Apr 16, 2019, at 2:54 PM, Dan Williams dan.j.williams@intel.com wrote:
>> 
>>> On Thu, Apr 11, 2019 at 1:54 PM Guenter Roeck <groeck@google.com> wrote:
>>> [..]
>>>> > > Boot tests report
>>>> > >
>>>> > > Qemu test results:
>>>> > >     total: 345 pass: 345 fail: 0
>>>> > >
>>>> > > This is on top of next-20190410 with CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
>>>> > > and the known crashes fixed.
>>>> >
>>>> > In addition to CONFIG_SHUFFLE_PAGE_ALLOCATOR=y you also need the
>>>> > kernel command line option "page_alloc.shuffle=1"
>>>> >
>>>> > ...so I doubt you are running with shuffling enabled. Another way to
>>>> > double check is:
>>>> >
>>>> >    cat /sys/module/page_alloc/parameters/shuffle
>>>>
>>>> Yes, you are right. Because, with it enabled, I see:
>>>>
>>>> Kernel command line: rdinit=/sbin/init page_alloc.shuffle=1 panic=-1
>>>> console=ttyAMA0,115200 page_alloc.shuffle=1
>>>> ------------[ cut here ]------------
>>>> WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:303
>>>> page_alloc_shuffle+0x12c/0x1ac
>>>> static_key_enable(): static key 'page_alloc_shuffle_key+0x0/0x4' used
>>>> before call to jump_label_init()
>>> 
>>> This looks to be specific to ARM never having had to deal with
>>> DEFINE_STATIC_KEY_TRUE in the past.
>>> 
>>> I am able to avoid this warning by simply not enabling JUMP_LABEL
>>> support in my build.
>> 
>> How large is your kernel image in memory ? Is it larger than 32MB
>> by any chance ?
>> 
>> On arm, the arch_static_branch() uses a "nop" instruction, which seems
>> fine. However, I have a concern wrt arch_static_branch_jump():
>> 
>> arch/arm/include/asm/jump_label.h defines:
>> 
>> static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
>> branch)
>> {
>>        asm_volatile_goto("1:\n\t"
>>                 WASM(b) " %l[l_yes]\n\t"
>>                 ".pushsection __jump_table,  \"aw\"\n\t"
>>                 ".word 1b, %l[l_yes], %c0\n\t"
>>                 ".popsection\n\t"
>>                 : :  "i" (&((char *)key)[branch]) :  : l_yes);
>> 
>>        return false;
>> l_yes:
>>        return true;
>> }
>> 
>> Which should work fine as long as the branch target is within +/-32MB range of
>> the branch instruction. However, based on
>> http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0489e/Cihfddaf.html
>> :
>> 
>> "Extending branch ranges
>> 
>> Machine-level B and BL instructions have restricted ranges from the address of
>> the current instruction. However, you can use these instructions even if label
>> is out of range. Often you do not know where the linker places label. When
>> necessary, the linker adds code to enable longer branches. The added code is
>> called a veneer."
>> 
>> So if by an odd chance this branch is turned into a longer branch by the linker,
>> then
>> the code pattern would be completely unexpected by arch/arm/kernel/jump_label.c.
>> 
>> Can you try with the following (untested) patch ?
> 

Updated logic of arch_static_branch_jump, and adding change that covers arch_static_branch()
as well (untested):

diff --git a/arch/arm/include/asm/jump_label.h b/arch/arm/include/asm/jump_label.h
index e12d7d096fc0..cec2f8a2b65e 100644
--- a/arch/arm/include/asm/jump_label.h
+++ b/arch/arm/include/asm/jump_label.h
@@ -9,12 +9,21 @@
 
 #define JUMP_LABEL_NOP_SIZE 4
 
+/*
+ * The linker adds veneer code if target of the branch is beyond +/-32MB
+ * range (+/-16MB for THUMB2), so ensure we never patch a branch
+ * instruction which target is outside of the inline asm.
+ */
 static __always_inline bool arch_static_branch(struct static_key *key, bool branch)
 {
        asm_volatile_goto("1:\n\t"
                 WASM(nop) "\n\t"
+                WASM(b) "2f\n\t"
+               "3:\n\t"
+                WASM(b) " %l[l_yes]\n\t"
+               "2:\n\t"
                 ".pushsection __jump_table,  \"aw\"\n\t"
-                ".word 1b, %l[l_yes], %c0\n\t"
+                ".word 1b, 3b, %c0\n\t"
                 ".popsection\n\t"
                 : :  "i" (&((char *)key)[branch]) :  : l_yes);
 
@@ -23,12 +32,21 @@ static __always_inline bool arch_static_branch(struct static_key *key, bool bran
        return true;
 }
 
+/*
+ * The linker adds veneer code if target of the branch is beyond +/-32MB
+ * range (+/-16MB for THUMB2), so ensure we never patch a branch
+ * instruction which target is outside of the inline asm.
+ */
 static __always_inline bool arch_static_branch_jump(struct static_key *key, bool branch)
 {
        asm_volatile_goto("1:\n\t"
+                WASM(b) "3f\n\t"
+                WASM(b) "2f\n\t"
+               "3:\n\t"
                 WASM(b) " %l[l_yes]\n\t"
+               "2:\n\t"
                 ".pushsection __jump_table,  \"aw\"\n\t"
-                ".word 1b, %l[l_yes], %c0\n\t"
+                ".word 1b, 3b, %c0\n\t"
                 ".popsection\n\t"
                 : :  "i" (&((char *)key)[branch]) :  : l_yes);


-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

