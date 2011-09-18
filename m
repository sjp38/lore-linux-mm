Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4ADA79000BD
	for <linux-mm@kvack.org>; Sun, 18 Sep 2011 14:58:32 -0400 (EDT)
Date: Sun, 18 Sep 2011 21:58:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 2/7] socket: initial cgroup code.
Message-ID: <20110918185830.GB28057@shutemov.name>
References: <1316051175-17780-1-git-send-email-glommer@parallels.com>
 <1316051175-17780-3-git-send-email-glommer@parallels.com>
 <20110917175207.GB1658@shutemov.name>
 <4E75664B.9070605@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E75664B.9070605@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org

On Sun, Sep 18, 2011 at 12:32:27AM -0300, Glauber Costa wrote:
> On 09/17/2011 02:52 PM, Kirill A. Shutemov wrote:
> > Do we really need to have these functions in the header?
> >
> No, I can move it to memcontrol.c
> 

Yes, please.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
