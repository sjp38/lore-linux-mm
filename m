Date: Tue, 26 Jun 2001 04:13:14 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [RFC] VM statistics to gather
In-Reply-To: <Pine.LNX.4.21.0106252238070.941-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0106260404450.1849-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Jun 2001, Marcelo Tosatti wrote:

> 
> On Mon, 25 Jun 2001, Rik van Riel wrote:
> 
> > Hi,
> > 
> > I am starting the process of adding more detailed instrumentation
> > to the VM subsystem and am wondering which statistics to add.
> > A quick start of things to measure are below, but I've probably
> > missed some things. Comments are welcome ...

	unsigned int vm_agepagedown; /* Count of age page down */
	unsigned int vm_agepageup;   /* Count of age page up */ 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
