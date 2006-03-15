Subject: Re: page migration: Fail with error if swap not setup
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 15 Mar 2006 09:47:33 -0500
Message-Id: <1142434053.5198.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-03-14 at 19:05 -0800, Christoph Lameter wrote:
> Currently the migration of anonymous pages will silently fail if no swap 
> is setup. This patch makes page migration functions check for available 
> swap and fail with -ENODEV if no swap space is available.

Migration Cache, anyone?  ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
