Date: Tue, 8 Mar 2005 18:35:07 -0800 (PST)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: Is there a way to do an architecture specific shake of memory?
In-Reply-To: <20050308211535.GB16061@lnx-holt.americas.sgi.com>
Message-ID: <Pine.LNX.4.58.0503081833430.10095@server.graphe.net>
References: <20050308211535.GB16061@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Mar 2005, Robin Holt wrote:

> Any suggestions are welcome.

Check when you free items how long the list of free items is and if its
too long free some of them.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
