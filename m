Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5386B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 02:58:23 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id tb5so23726852lbb.3
        for <linux-mm@kvack.org>; Thu, 12 May 2016 23:58:23 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id bs2si20629722wjb.154.2016.05.12.23.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 23:58:22 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n129so1754882wmn.1
        for <linux-mm@kvack.org>; Thu, 12 May 2016 23:58:22 -0700 (PDT)
Date: Fri, 13 May 2016 08:58:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/19] get rid of superfluous __GFP_REPEAT
Message-ID: <20160513065820.GD20141@dhcp22.suse.cz>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
 <20160512165310.GB4940@dhcp22.suse.cz>
 <20160512131328.b2b45b2f6b6847b882286424@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160512131328.b2b45b2f6b6847b882286424@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Chen Liqin <liqin.linux@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Heiko Carstens <heiko.carstens@de.ibm.com>, Helge Deller <deller@gmx.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, John Crispin <blogic@openwrt.org>, Lennox Wu <lennox.wu@gmail.com>, Ley Foon Tan <lftan@altera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Fleming <matt@codeblueprint.co.uk>, Mikulas Patocka <mpatocka@redhat.com>, Rich Felker <dalias@libc.org>, Russell King <linux@arm.linux.org.uk>, Shaohua Li <shli@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Thomas Gleixner <tglx@linutronix.de>, Vineet Gupta <vgupta@synopsys.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>

On Thu 12-05-16 13:13:28, Andrew Morton wrote:
> On Thu, 12 May 2016 18:53:11 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Andrew,
> > do you think this should go in in the next merge window or should I
> > repost after rc1 is out? I do not mind one way or the other. I would
> > obviously would like to get them in sooner rather than later but I can
> > certainly live with these wait a bit longer.
> 
> Yup, after -rc1 would suit.  Or resend them now and I'll queue them for
> 4.7-rc2.

OK, rc2 sounds good as well. It is mostly cleanup without any visible
effect.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
