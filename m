Message-ID: <20020405195537.22641.qmail@london.rubylane.com>
From: jim@rubylane.com
Subject: Re: 2.2.20 suspends everything then recovers during heavy I/O
Date: Fri, 5 Apr 2002 11:55:37 -0800 (PST)
In-Reply-To: <20020405195240.22435.qmail@london.rubylane.com> from "jim@rubylane.com" at Apr 05, 2002 11:52:40 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jim@rubylane.com
Cc: Martin.Bligh@us.ibm.com, Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I just realized, you are probably talking about raw IO on a file, not
raw IO on a partition like dump.  I don't know anything about it so
my ignorance is starting to show here... :)

J

> > 
> > Doesn't the raw IO stuff do this, effectively?
> > 
> > M.
> > 
> > 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
