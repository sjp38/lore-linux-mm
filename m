Date: Fri, 18 Jul 2003 16:32:41 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [2.6.0-test1-mm1] Compile varnings
Message-ID: <20030718233241.GJ1583@kroah.com>
References: <1058387502.13489.2.camel@sm-wks1.lan.irkk.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1058387502.13489.2.camel@sm-wks1.lan.irkk.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Axelsson <smiler@lanil.mine.nu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 16, 2003 at 10:31:42PM +0200, Christian Axelsson wrote:
> Here is an i2c related warning:
> 
> CC      drivers/i2c/i2c-dev.o
> drivers/i2c/i2c-dev.c: In function `show_dev':
> drivers/i2c/i2c-dev.c:121: warning: unsigned int format, different type
> arg (arg 3)

I've posted a patch to fix this warning.  Look in the archives.

thanks,

greg k-h
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
