Date: Wed, 4 Sep 2002 20:25:23 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: 2.5.33-mm1
Message-ID: <20020904202523.A15699@redhat.com>
References: <200209032251.54795.tomlins@cam.org> <3D757F11.B72BB708@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D757F11.B72BB708@zip.com.au>; from akpm@zip.com.au on Tue, Sep 03, 2002 at 08:33:37PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Ed Tomlinson <tomlins@cam.org>, William Lee Irwin III <wli@holomorphy.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Sep 03, 2002 at 08:33:37PM -0700, Andrew Morton wrote:

> I *really* think we need to throw away those pages instantly.
> 
> The only possible reason for hanging onto them is because they're
> cache-warm.  And we need a global-scope cpu-local hot pages queue
> anyway.

Yep --- except for caches with constructors, for which we do save a
bit more by hanging onto the pages for longer.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
