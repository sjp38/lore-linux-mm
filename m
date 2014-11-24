Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2A36C6B00C0
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 12:26:02 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so6445704wib.10
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:26:01 -0800 (PST)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id d6si13154604wiz.67.2014.11.24.09.26.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 09:26:01 -0800 (PST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so6613355wid.12
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:26:01 -0800 (PST)
Date: Mon, 24 Nov 2014 18:25:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH 0/5] mm: Patches for mitigating memory allocation
 stalls.
Message-ID: <20141124172558.GF11745@curandero.mameluci.net>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Sun 23-11-14 13:49:27, Tetsuo Handa wrote:
[...]
>       I reported this vulnerability last year and a CVE number was assigned,
>       but no progress has been made. If a malicious local user notices a
>       patchset that mitigates/fixes this vulnerability, the user is free to
>       attack existing Linux systems. Therefore, I propose this patchset before
>       any patchset that mitigates/fixes this vulnerability is proposed.

I have looked at patches and I do not believe they address anything.
They seem like random and ad-hoc hacks which pretend to solve a class of
problems but in fact only paper over potentially real ones.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
