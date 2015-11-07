Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 85B2082F64
	for <linux-mm@kvack.org>; Sat,  7 Nov 2015 13:12:18 -0500 (EST)
Received: by ioc74 with SMTP id 74so86094578ioc.2
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 10:12:18 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0062.hostedemail.com. [216.40.44.62])
        by mx.google.com with ESMTP id o19si4258044igs.94.2015.11.07.10.12.17
        for <linux-mm@kvack.org>;
        Sat, 07 Nov 2015 10:12:17 -0800 (PST)
Message-ID: <1446919935.2701.2.camel@perches.com>
Subject: Re: [PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()
From: Joe Perches <joe@perches.com>
Date: Sat, 07 Nov 2015 10:12:15 -0800
In-Reply-To: <1446896665-21818-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: 
	<1446896665-21818-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 2015-11-07 at 20:44 +0900, Tetsuo Handa wrote:
> bm_vk_free

Might as well get rid of the static function altogether.
Maybe in a follow-on patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
