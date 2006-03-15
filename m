Date: Wed, 15 Mar 2006 10:20:25 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
In-Reply-To: <20060315101402.3b19330c.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0603151019490.27289@schroedinger.engr.sgi.com>
References: <1142019195.5204.12.camel@localhost.localdomain>
 <20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com>
 <1142270857.5210.50.camel@localhost.localdomain>
 <Pine.LNX.4.64.0603131541330.13713@schroedinger.engr.sgi.com>
 <44183B64.3050701@argo.co.il> <20060315095426.b70026b8.pj@sgi.com>
 <Pine.LNX.4.64.0603151008570.27212@schroedinger.engr.sgi.com>
 <20060315101402.3b19330c.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, avi@argo.co.il, lee.schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Mar 2006, Paul Jackson wrote:

> The point was to copy pages that receive many
> load and store instructions from far away nodes.

Right. In order to do that we first need to have some memory traces or 
statistics that can establish that a page is accessed from far away nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
