Date: Wed, 02 Oct 2002 14:49:43 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: NUMA is bust with CONFIG_PREEMPT=y
Message-ID: <384860000.1033595383@flay>
In-Reply-To: <3D9B6939.397DB9EA@digeo.com>
References: <3D9B6939.397DB9EA@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Either you're going to have to change that to get_cpu_only_on_numa() and
> add the matching put_cpu_only_on_numa()'s, or disable preempt in
> the config system.

I'd favour the latter. It doesn't seem that useful on big machines like this, and
adds significant complication ... anyone really want it on a NUMA box? If not,
I'll make a patch to disable it for NUMA machines ...

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
