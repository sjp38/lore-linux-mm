Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 663446B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 04:07:55 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id z7so1037512eaf.14
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 01:07:53 -0700 (PDT)
Date: Sun, 4 Aug 2013 10:07:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
Message-ID: <20130804080751.GA24005@dhcp22.suse.cz>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
 <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
 <51F9D1F6.4080001@jp.fujitsu.com>
 <20130731201708.efa5ae87.akpm@linux-foundation.org>
 <CAHGf_=r7mek+ueJWfu_6giMOueDTnMs8dY1jJrKyX+gfPys6uA@mail.gmail.com>
 <20130802073304.GA17746@dhcp22.suse.cz>
 <51FD653A.3060004@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51FD653A.3060004@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, dave@linux.vnet.ibm.com

On Sat 03-08-13 16:16:58, KOSAKI Motohiro wrote:
> >>> You missed the "!".  I'm proposing that setting the new bit 2 will
> >>> permit people to prevent the new printk if it is causing them problems.
> >>
> >> No I don't. I'm sure almost all abuse users think our usage is correct. Then,
> >> I can imagine all crazy applications start to use this flag eventually.
> > 
> > I guess we do not care about those. If somebody wants to shoot his feet
> > then we cannot do much about it. The primary motivation was to find out
> > those that think this is right and they are willing to change the setup
> > once they know this is not the right way to do things.
> > 
> > I think that giving a way to suppress the warning is a good step. Log
> > level might be to coarse and sysctl would be an overkill.
> 
> When Dave Hansen reported this issue originally, he explained a lot of userland
> developer misuse /proc/drop_caches because they don't understand what
> drop_caches do.
> So, if they never understand the fact, why can we trust them? I have no
> idea.

Well, most of that usage I have come across was legacy scripts which
happened to work at a certain point in time because we sucked.
Thinks have changed but such scripts happen to survive a long time.
We are primarily interested in those.

> Or, if you have different motivation w/ Dave, please let me know it.

We have seen reports where users complained about performance drop down
when in fact the real culprit turned out to be such a clever script
which dropped caches on the background thinking it will help to free
some memory. Such cases are tedious to reveal.

> While the purpose is to shoot misuse, I don't think we can trust
> userland app.  If "If somebody wants to shoot his feet then we cannot
> do much about it." is true, this patch is useless. OK, we still catch
> the right user.

I do not think it is useless. It will print a message for all those
users initially. It is a matter of user how to deal with it.

> But we never want to know who is the right users, right?

Well, those that are curious about a new message in the lock and come
back to us asking what is going on are those we are primarily interested
in.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
