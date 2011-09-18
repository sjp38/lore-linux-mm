Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 839579000BD
	for <linux-mm@kvack.org>; Sun, 18 Sep 2011 16:39:33 -0400 (EDT)
Date: Sun, 18 Sep 2011 23:39:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 1/7] Basic kernel memory functionality for the Memory
 Controller
Message-ID: <20110918203931.GA28611@shutemov.name>
References: <1316051175-17780-1-git-send-email-glommer@parallels.com>
 <1316051175-17780-2-git-send-email-glommer@parallels.com>
 <20110917174535.GA1658@shutemov.name>
 <4E7567E0.9010401@parallels.com>
 <20110918190509.GC28057@shutemov.name>
 <4E764259.5070209@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E764259.5070209@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org

On Sun, Sep 18, 2011 at 04:11:21PM -0300, Glauber Costa wrote:
> On 09/18/2011 04:05 PM, Kirill A. Shutemov wrote:
> > On Sun, Sep 18, 2011 at 12:39:12AM -0300, Glauber Costa wrote:
> >>> Always zero in root cgroup?
> >>
> >> Yes, if we're not accounting, it should be zero. WARN_ON, maybe?
> >
> > -ENOSYS?
> >
> I'd personally prefer WARN_ON. It is good symmetry from userspace PoV to 
> always be able to get a value out of it. Also, it something goes wrong 
> and it is not zero for some reason, this will help us find it.

What's the point to get non-relevant value?
What about -ENOSYS + WARN_ON?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
