Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2756B03F0
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 05:46:26 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 26so288456012pgy.6
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 02:46:26 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u4si2618025plj.12.2016.12.22.02.46.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 02:46:24 -0800 (PST)
Subject: Re: OOM: Better, but still there on
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161220020829.GA5449@boerne.fritz.box>
	<20161221073658.GC16502@dhcp22.suse.cz>
	<20161222101028.GA11105@ppc-nas.fritz.box>
	<20161222102725.GG6048@dhcp22.suse.cz>
	<20161222103524.GA14020@ppc-nas.fritz.box>
In-Reply-To: <20161222103524.GA14020@ppc-nas.fritz.box>
Message-Id: <201612221946.EHB81270.FVHFMLSQOOtJFO@I-love.SAKURA.ne.jp>
Date: Thu, 22 Dec 2016 19:46:14 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nholland@tisys.org, mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, dsterba@suse.cz, linux-btrfs@vger.kernel.org

Nils Holland wrote:
> Well, the issue is that I could only do everything via ssh today and
> don't have any physical access to the machines. In fact, both seem to
> have suffered a genuine kernel panic, which is also visible in the
> last few lines of the log I provided today. So, basically, both
> machines are now sitting at my home in panic state and I'll only be
> able to resurrect them wheh I'm physically there again tonight.

# echo 10 > /proc/sys/kernel/panic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
