Received: by nf-out-0910.google.com with SMTP id b2so1072869nfe
        for <linux-mm@kvack.org>; Sat, 24 Feb 2007 00:24:21 -0800 (PST)
Message-ID: <45a44e480702240024w30c0c2e2uaa01f3ed8f7457c2@mail.gmail.com>
Date: Sat, 24 Feb 2007 03:24:20 -0500
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: [RFC 2.6.20 1/1] fbdev,mm: Deferred IO and hecubafb driver
In-Reply-To: <20070223092237.GA16889@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070223063228.GA9906@localhost>
	 <20070223092237.GA16889@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Jaya Kumar <jayakumar.lkml@gmail.com>, linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/23/07, Paul Mundt <lethal@linux-sh.org> wrote:
> On Fri, Feb 23, 2007 at 07:32:28AM +0100, Jaya Kumar wrote:
> > This is a first pass at abstracting deferred IO out from hecubafb and
> > into fbdev as was discussed before:
> > http://marc.theaimsgroup.com/?l=linux-fbdev-devel&m=117187443327466&w=2
> >
> > Please let me know your feedback and if it looks okay so far.
> >
> How about this for an fsync()? I wonder if this will be sufficient for
> msync() based flushing, or whether the ->sync VMA op is needed again..
>

Looks fine to me.

Thanks,
jaya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
