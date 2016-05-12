Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9072E6B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 16:13:31 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gw7so120321187pac.0
        for <linux-mm@kvack.org>; Thu, 12 May 2016 13:13:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x190si19315597pfx.222.2016.05.12.13.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 13:13:30 -0700 (PDT)
Date: Thu, 12 May 2016 13:13:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/19] get rid of superfluous __GFP_REPEAT
Message-Id: <20160512131328.b2b45b2f6b6847b882286424@linux-foundation.org>
In-Reply-To: <20160512165310.GB4940@dhcp22.suse.cz>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
	<20160512165310.GB4940@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Chen Liqin <liqin.linux@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Heiko Carstens <heiko.carstens@de.ibm.com>, Helge Deller <deller@gmx.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, John Crispin <blogic@openwrt.org>, Lennox Wu <lennox.wu@gmail.com>, Ley Foon Tan <lftan@altera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Fleming <matt@codeblueprint.co.uk>, Mikulas Patocka <mpatocka@redhat.com>, Rich Felker <dalias@libc.org>, Russell King <linux@arm.linux.org.uk>, Shaohua Li <shli@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Thomas Gleixner <tglx@linutronix.de>, Vineet Gupta <vgupta@synopsys.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>

On Thu, 12 May 2016 18:53:11 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> Andrew,
> do you think this should go in in the next merge window or should I
> repost after rc1 is out? I do not mind one way or the other. I would
> obviously would like to get them in sooner rather than later but I can
> certainly live with these wait a bit longer.

Yup, after -rc1 would suit.  Or resend them now and I'll queue them for
4.7-rc2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
