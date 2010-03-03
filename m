Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 90E376B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 16:02:38 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: unable to handle kernel paging request on resume with 2.6.33-00001-gbaac35c
Date: Wed, 3 Mar 2010 22:04:51 +0100
References: <20100301175256.GA4034@tiehlicka.suse.cz> <201003022101.21521.rjw@sisk.pl> <20100303102621.GC4241@tiehlicka.suse.cz>
In-Reply-To: <20100303102621.GC4241@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201003032204.51167.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mstsxfx@gmail.com>
Cc: linux-kernel@vger.kernel.org, pm list <linux-pm@lists.linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 03 March 2010, Michal Hocko wrote:
> On Tue, Mar 02, 2010 at 09:01:21PM +0100, Rafael J. Wysocki wrote:
> > On Tuesday 02 March 2010, Michal Hocko wrote:
...
> > So this is just plain 2.6.33 plus one commit.
> > 
> > Hmm.  There are only a few changes directly related to hibernation in that
> > kernel and none of them can possibly introduce a problem like that.
> 
> My previous kernel was vmlinux-2.6.33-rc8-00164-gaea187c and it didn't
> show the problem.

Well, I have no idea which of the commits between -rc8 and .33 final might
introduce such a problem.

What graphics is there in the affected box?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
