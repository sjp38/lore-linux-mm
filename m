Date: Tue, 20 Jan 2004 16:34:34 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: I2C sensors error (Re: 2.6.1-mm5)
Message-ID: <20040121003434.GC5472@kroah.com>
References: <20040120000535.7fb8e683.akpm@osdl.org> <20040120191040.2e1b46a9.winkie@linuxfromscratch.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040120191040.2e1b46a9.winkie@linuxfromscratch.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zack Winkles <winkie@linuxfromscratch.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 20, 2004 at 07:10:40PM -0500, Zack Winkles wrote:
> Yo,
> 
> As usual, I've upgraded to the latest -mm, but to my dismay, my
> temperature sensors are no longer reporting sane values.  For example,
> my motherboard usually reports about 31C, but now never moves up or down
> from 210C.  My CPU, likewise, hovers at 210C, but sometimes moves up or
> down in what appears to be units of 11.
> 
> I'm positive in the correctness of my /sys value parsing (latest gkrellm
> drop with lm_sensors values stuck in), so that's a non-issue.  The
> modules I'm using are i2c_viapro and w83781d, and of course their
> dependencies.  My logs report no errors from the kernel, or any user
> space apps/libs of relevance.

Please make sure you have the latest version of lmsensors.  A few things
have changed in the latest i2c driver code that makes this necessary (we
don't initialize chips from the kernel anymore, which might be what you
are seeing.)

If that still doesn't work, please post this to the sensors mailing list
(address is in the MAINTAINERS file.)

thanks,

greg k-h
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
