Date: Fri, 17 Oct 2003 15:02:46 -0400 (EDT)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: 2.6.0-test7-mm1 4G/4G hanging at boot
In-Reply-To: <Pine.LNX.4.44.0310171441530.3108-100000@chimarrao.boston.redhat.com>
Message-ID: <Pine.LNX.4.53.0310171501360.2831@montezuma.fsmlabs.com>
References: <Pine.LNX.4.44.0310171441530.3108-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, lkml <linux-kernel@vger.kernel.org>, mingo@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Oct 2003, Rik van Riel wrote:

> On Fri, 17 Oct 2003, Randy.Dunlap wrote:
> 
> > then I wait for 1-2 minutes and hit the power button.
> > This is on an IBM dual-proc P4 (non-HT) with 1 GB of RAM.
> > 
> > Has anyone else seen this?  Suggestions or fixes?
> 
> Chances are the 8kB stack window isn't 8kB aligned in the
> fixmap area, because of other patches interfering.  Try
> adding a dummy fixmap page to even things out.

Check the email with subject;
[PATCH][2.6] Fix 4G/4G and WP test lockup

Another thing is, you shouldn't be branching off to that test! Which gcc 
compiler are you using?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
