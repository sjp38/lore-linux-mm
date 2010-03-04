Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1B29D6B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 04:02:10 -0500 (EST)
Date: Thu, 4 Mar 2010 10:02:07 +0100
From: Michal Hocko <mstsxfx@gmail.com>
Subject: Re: unable to handle kernel paging request on resume with
 2.6.33-00001-gbaac35c
Message-ID: <20100304090207.GA4640@tiehlicka.suse.cz>
References: <20100301175256.GA4034@tiehlicka.suse.cz>
 <201003022101.21521.rjw@sisk.pl>
 <20100303102621.GC4241@tiehlicka.suse.cz>
 <201003032204.51167.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201003032204.51167.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-kernel@vger.kernel.org, pm list <linux-pm@lists.linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 03, 2010 at 10:04:51PM +0100, Rafael J. Wysocki wrote:
> On Wednesday 03 March 2010, Michal Hocko wrote:
> > On Tue, Mar 02, 2010 at 09:01:21PM +0100, Rafael J. Wysocki wrote:
> > > On Tuesday 02 March 2010, Michal Hocko wrote:
> ...
> > > So this is just plain 2.6.33 plus one commit.
> > > 
> > > Hmm.  There are only a few changes directly related to hibernation in that
> > > kernel and none of them can possibly introduce a problem like that.
> > 
> > My previous kernel was vmlinux-2.6.33-rc8-00164-gaea187c and it didn't
> > show the problem.
> 
> Well, I have no idea which of the commits between -rc8 and .33 final might
> introduce such a problem.
> 
> What graphics is there in the affected box?

00:02.1 Display controller: Intel Corporation Mobile 945GM/GMS/GME,
943/940GML Express Integrated Graphics Controller (rev 03))

> 
> Rafael

-- 
Michal Hocko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
