Return-Path: <owner-linux-mm@kvack.org>
Date: Fri, 18 Feb 2011 11:03:06 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: incomplete emails from kvack.org
Message-ID: <20110218160306.GE2507@kvack.org>
References: <20110218145932.GA4862@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110218145932.GA4862@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org

On Fri, Feb 18, 2011 at 03:59:32PM +0100, Michal Hocko wrote:
> Hi,
> 
> I have seen incomplete emails coming from kvack.org mailing list
> recently. I cannot say since when because I have ignored it for some
...
> Is this a known issue?
> 
> [1] http://marc.info/?l=linux-mm&m=129781446430960&w=2
> [2] https://lkml.org/lkml/2011/2/15/361

Hugh Dickins already reported the issue earlier this week and it has been 
fixed.  Emails with a single period on the beginning of a line were being 
truncated.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
