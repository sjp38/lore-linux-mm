From: Zach Brown <zab@zabbo.net>
Subject: Re: [RFC][PATCH] Interface to invalidate regions of mmaps
Date: Tue, 13 May 2003 16:57:36 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3EC18670.8070103@zabbo.net>
References: <20030513133636.C2929@us.ibm.com>	<20030513152141.5ab69f07.akpm@digeo.com>	<3EC17BA3.7060403@zabbo.net> <20030513161938.1fc00a5e.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
In-Reply-To: <20030513161938.1fc00a5e.akpm@digeo.com>
To: Andrew Morton <akpm@digeo.com>
Cc: paulmck@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mjbligh@us.ibm.com
List-Id: linux-mm.kvack.org


> In 2.5, page->buffers was abstracted out to page->private, and is available
> to filesystems for functions such as this.

that's great news!

> When you finally decide to do your development in a development kernel ;)

customers seem to have the strangest aversion to  development kernels :)

but, yeah, I should be doing 2.5 work soon and will holler if
simplifications make themselves apparent.

- z
