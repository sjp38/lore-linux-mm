Date: Mon, 06 Dec 2004 14:44:23 +0000
From: Miquel van Smoorenburg <miquels@cistron.nl>
Subject: Re: pages not marked as accessed on non-page boundaries
References: <20041205141342.GA29174@cistron.nl>
	<Pine.LNX.4.61.0412050944040.5582@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0412050944040.5582@chimarrao.boston.redhat.com>
	(from riel@redhat.com on Sun Dec  5 15:44:37 2004)
Message-Id: <1102344263l.12264l.3l@traveler>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2004.12.05 15:44, Rik van Riel wrote:
> On Sun, 5 Dec 2004, Miquel van Smoorenburg wrote:
> 
> > When you have a database accessing small amounts of data
> > in an index file randomly, then most of those pages will
> > not be marked as read and will be thrown out too soon.
> 
> > Would it be a good thing to fix this ? Patch is below.
> 
> Your patch makes a lot of sense to me.  This should help
> keep database indexes in memory...

Okay I'll send it on to Andrew then for -mm tonight or tomorrow.

Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
