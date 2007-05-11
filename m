Date: Fri, 11 May 2007 10:08:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory hotremove patch take 2 [01/10] (counter of
 removable page)
Message-Id: <20070511100851.f7d18ae8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <p73bqgsg5ef.fsf@bingen.suse.de>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
	<20070509120132.B906.Y-GOTO@jp.fujitsu.com>
	<p73bqgsg5ef.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: y-goto@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org, clameter@sgi.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On 10 May 2007 15:44:08 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> Yasunori Goto <y-goto@jp.fujitsu.com> writes:
> 
> 
> (not a full review, just something I noticed)
> > @@ -352,6 +352,8 @@ struct sysinfo {
> >  	unsigned short pad;		/* explicit padding for m68k */
> >  	unsigned long totalhigh;	/* Total high memory size */
> >  	unsigned long freehigh;		/* Available high memory size */
> > +	unsigned long movable;		/* pages used only for data */
> > +	unsigned long free_movable;	/* Avaiable pages in movable */
> 
> You can't just change that structure, it is exported to user space.
> 
Okay. We'll drop this.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
