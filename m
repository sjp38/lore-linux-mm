Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id EABDF90008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:59:40 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id l13so2371154iga.15
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 14:59:40 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0083.hostedemail.com. [216.40.44.83])
        by mx.google.com with ESMTP id t4si8759577icw.27.2014.10.29.14.59.40
        for <linux-mm@kvack.org>;
        Wed, 29 Oct 2014 14:59:40 -0700 (PDT)
Message-ID: <1414619976.2542.1.camel@perches.com>
Subject: Re: mmotm 2014-10-29-14-19 uploaded
From: Joe Perches <joe@perches.com>
Date: Wed, 29 Oct 2014 14:59:36 -0700
In-Reply-To: <alpine.DEB.2.11.1410292233340.5308@nanos>
References: <54515a25.46WrYSce5BExT3V4%akpm@linux-foundation.org>
	 <alpine.DEB.2.11.1410292233340.5308@nanos>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

On Wed, 2014-10-29 at 22:37 +0100, Thomas Gleixner wrote:
> On Wed, 29 Oct 2014, akpm@linux-foundation.org wrote:
> > This mmotm tree contains the following patches against 3.18-rc2:
> > (patches marked "*" will be included in linux-next)
> > 
> > * kernel-posix-timersc-code-clean-up.patch
> 
> Can you please drop this pointless churn? We really can replace all
> that stuff with a shell script and let it run over the tree every now
> and then.

Should any automated code reformatting really be done
by an unsupervised or unreviewed shell script?

Likely not.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
