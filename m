Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0AA6C31E46
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 01:00:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B87B21721
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 01:00:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="03XL9DAV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B87B21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE0B46B000C; Wed, 12 Jun 2019 21:00:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D91006B000E; Wed, 12 Jun 2019 21:00:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C59006B0010; Wed, 12 Jun 2019 21:00:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3266B000C
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 21:00:34 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 21so12583788pgl.5
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:00:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DarkrN9UGsVxHvmogjtXUy/PWGo8fNu6IG4JYRKrWZM=;
        b=hkjXxYzMyw0sBsatCcEk+4NBi6EJ9q7+C/b2F0IRJmhWdOJ4e0NsPytt/qT5rTjSXG
         wxj5R6es0itx47G+0jxcE9dJoMiqK9ODhC8SZoBD+gZaeuotBLu0OM/os/ZC+yCtepqh
         IRQpRlLan1V/4K6dVsqM0WHtimGX5omC/WAQEy41vxNvvVQrlO4LEWpOnyO7sMFlQSFq
         lmjROHOSEGkVwVzmWF7uy1wAC24UOEOvSsPnGHRGk3JzyqGv5eiKr9Gp14+kkiXqJDQk
         cEqhJLDOQnBs5wm7V0oRyVWBcOb/XgkVsatLpGeuH/1mOdcHC8gDBxmCsLwZj51XfDOY
         muJg==
X-Gm-Message-State: APjAAAWNFMdjOYRttbVuWAHcAXfoRTssRtlsR9DYdH6FmhyKFYNzYmUL
	FuNr+VI4DLCut3M2jaS1nDZ3E5tgTOsiPumXqBYxtRpHixyPXd3LQ8VMKTP4XxxbRN12i6mzMbc
	O6ohZ27kVJEflGFvJ3Cj0NeRIwsQpClA5cLNTgkFWlJvk5XjcNvHYeFW/txO0njeA7g==
X-Received: by 2002:a63:1844:: with SMTP id 4mr25628934pgy.402.1560387634089;
        Wed, 12 Jun 2019 18:00:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTG8048rS/6BS+ZAjwaxu8KRYeMkz00xCHHhet4RZMgswqmDorO6ukWwdwyz2+p7ucorcn
X-Received: by 2002:a63:1844:: with SMTP id 4mr25628871pgy.402.1560387633093;
        Wed, 12 Jun 2019 18:00:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560387633; cv=none;
        d=google.com; s=arc-20160816;
        b=Exl+BKTioakEY28QIOJQ4SQhUcMf2RF7BMucRTIwwNAHyy9Eva+5+Qmgnym3UQIKAa
         LgR+B5U2NLNgWQmz8XxmC+dLLt9SWO3S7QVO6POLPHVLS4G4fuBLkuGdIYeF6ss9oaO0
         xd6oMy1H1khCkFQCrAVbFJTAbM17qhwWcS+l9e5ACPRLZP1WlAFrUQt80Pr+K8E7mQUm
         nn//LcmAqE+ip6efhHYeHlKmhIpZpbXl3F9I17ajewRIX4Yw4wi/L0eculgR1nvdHjZ3
         x2rnW84Ke0R4yJ0kaCGidgZaSOhpNjaw9f/Of+wyYrNwPEKupBn4pndkpWHzoxQJwaKN
         TDbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DarkrN9UGsVxHvmogjtXUy/PWGo8fNu6IG4JYRKrWZM=;
        b=r31d1ug0LSjFIkP1NODX0yKet7K8RRTC2FrKMzC4PrHxk6pr4d9NbhoLFwR2i8JdYp
         Uzb0UapSk7qsUpn4PS9cg2+d2uAsClwU2KEL/Jpv9RQNEDogvA0Z9Op80Ke/jwxXlteV
         EFnNOB7pGfhOsHrZALFQeyGSIonmp0/M0OVEnqXYYXclSNeuE5pM7FSFB2QI1XiTVeFa
         Xc78K7DkH/dyaK4Xp5ZrEjRIM7cgyUPQKUUNZxZgx9fTsZhzUyiunKM740tkB9DtmvfD
         ZQ8aV/qqe9xZMfb948/IDSjyX4imD+v6EEEG49oteI+VN9ufZzA5o8ix54M98KMzOSfn
         +oFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=03XL9DAV;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c1si1091777pld.418.2019.06.12.18.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 18:00:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=03XL9DAV;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 80DD520B7C;
	Thu, 13 Jun 2019 01:00:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560387632;
	bh=WUexA2+dp05oChEUY0hVcSnJGehxfowRO2+SZ2+eUDI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=03XL9DAVVWVD08SCihXoCb+VMg14Qe4N0JjLvI2qz6yWLN8k3lI5jhzDJ4oQpOh73
	 ODhE/FDdjsYf0cN14H2V8IPabHV05TMOWNJnCPwwOCy0nrZ1Q/384BAQ5PcqarQ/gU
	 KnjV1EfqhlRVRJ0s3WFfskPMF5KWnCWHeROGM/ZQ=
Date: Wed, 12 Jun 2019 18:00:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Joel Savitz <jsavitz@redhat.com>
Cc: linux-kernel@vger.kernel.org, Rafael Aquini <aquini@redhat.com>, David
 Rientjes <rientjes@google.com>, linux-mm@kvack.org
Subject: Re: [RESEND PATCH v2] mm/oom_killer: Add task UID to info message
 on an oom kill
Message-Id: <20190612180031.e9314711c9d0c77ba915d977@linux-foundation.org>
In-Reply-To: <1560362273-534-1-git-send-email-jsavitz@redhat.com>
References: <1560362273-534-1-git-send-email-jsavitz@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jun 2019 13:57:53 -0400 Joel Savitz <jsavitz@redhat.com>
wrote:

> In the event of an oom kill, useful information about the killed
> process is printed to dmesg. Users, especially system administrators,
> will find it useful to immediately see the UID of the process.
> 
> In the following example, abuse_the_ram is the name of a program
> that attempts to iteratively allocate all available memory until it is
> stopped by force.
> 
> Current message:
> 
> Out of memory: Killed process 35389 (abuse_the_ram)
> total-vm:133718232kB, anon-rss:129624980kB, file-rss:0kB,
> shmem-rss:0kB
> 
> Patched message:
> 
> Out of memory: Killed process 2739 (abuse_the_ram),
> total-vm:133880028kB, anon-rss:129754836kB, file-rss:0kB,
> shmem-rss:0kB, UID 0

The other fields are name:value so it seems better to make the UID
field conform.

Also, there's no typesafe way of printing a uid_t (using the printk %p trick)
so yes, we have to assume its type.  But assuming unsigned int is
better than assuming int!

So...



s/UID %d/UID:%u/ in printk

--- a/mm/oom_kill.c~mm-oom_killer-add-task-uid-to-info-message-on-an-oom-kill-fix
+++ a/mm/oom_kill.c
@@ -876,7 +876,7 @@ static void __oom_kill_process(struct ta
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
 	mark_oom_victim(victim);
-	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB, UID %d\n",
+	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB, UID:%u\n",
 		message, task_pid_nr(victim), victim->comm,
 		K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
_

