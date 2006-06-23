Date: Fri, 23 Jun 2006 12:00:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: linux-mm remailer eats [PATCH xx/yy] subject lines?
In-Reply-To: <20060623185828.GB13617@kvack.org>
Message-ID: <Pine.LNX.4.64.0606231159310.7339@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0606221141450.30988@schroedinger.engr.sgi.com>
 <20060623185828.GB13617@kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jun 2006, Benjamin LaHaise wrote:

> On Thu, Jun 22, 2006 at 11:43:50AM -0700, Christoph Lameter wrote:
> > We noticed that many of my emails to this list have the [PATCH ...] 
> > subject part removed from it. The mails to lkml arrive just fine. The cc 
> > that I am getting is also okay. Anyone have a clue?
> 
> That shouldn't be happening unless bogofilter is catching it as spam.  The 
> few items that are marked unsure are usually approved by me within a short 
> period of time.  If you have a particular example, I can dig through the 
> logs to see what happened.

Have a look at the zoned VM counter patch V6 that was posted recently to 
linux-mm. The first two patches have the [] intact the later 12 have them 
all removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
