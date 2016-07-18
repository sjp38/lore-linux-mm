Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59B566B0261
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 03:24:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so108520217lfi.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 00:24:30 -0700 (PDT)
Received: from mail.ud19.udmedia.de (ud19.udmedia.de. [194.117.254.59])
        by mx.google.com with ESMTPS id c132si13213772wma.108.2016.07.18.00.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 00:24:28 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Mon, 18 Jul 2016 09:24:28 +0200
From: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Subject: Re: Page Allocation Failures/OOM with dm-crypt on software RAID10
 (Intel Rapid Storage) with check/repair/sync
In-Reply-To: <005574d77d3f5dbc2643044a1e2468dc@mail.ud19.udmedia.de>
References: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
 <20160712095013.GA14591@dhcp22.suse.cz>
 <d9dbe0328e938eb7544fdb2aa8b5a9c7@mail.ud19.udmedia.de>
 <20160712114920.GF14586@dhcp22.suse.cz>
 <e6c2087730e530e77c2b12d50495bdc9@mail.ud19.udmedia.de>
 <20160712140715.GL14586@dhcp22.suse.cz>
 <459d501038de4d25db6d140ac5ea5f8d@mail.ud19.udmedia.de>
 <20160713112126.GH28723@dhcp22.suse.cz>
 <20160713121828.GI28723@dhcp22.suse.cz>
 <74b9325c37948cf2b460bd759cff23dd@mail.ud19.udmedia.de>
 <20160713134717.GL28723@dhcp22.suse.cz>
 <9074e82f-bf52-011e-8bd7-5731d2b0dcaa@I-love.SAKURA.ne.jp>
 <005574d77d3f5dbc2643044a1e2468dc@mail.ud19.udmedia.de>
Message-ID: <3e08f5186a4650775a56bd0aabad6a44@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-raid@vger.kernel.org
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Michal Hocko <mhocko@kernel.org>, Mike Snitzer <snitzer@redhat.com>, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org

Hello again...

So I spent all weekend doing further tests, since this issue is
really bugging me for obvious reasons.

I thought it would be beneficial if I created a bug report that
summarized and centralized everything in one place rather than
having everything spread across several lists and posts.

Here the bug report I created:
https://bugzilla.kernel.org/show_bug.cgi?id=135481

If anyone has any suggestions, ideas or wants me to do further tests,
please just let me know. There is not much more I can do at this point
without further help/guidance.

Thanks,
Matthias

-- 
Dipl.-Inf. (FH) Matthias Dahl | Software Engineer | binary-island.eu
  services: custom software [desktop, mobile, web], server administration

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
