Date: Thu, 15 Aug 2002 21:31:40 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] add buddyinfo /proc entry
Message-ID: <20020816043140.GA2478@kroah.com>
References: <3D5C6410.1020706@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D5C6410.1020706@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2002 at 07:31:44PM -0700, Dave Hansen wrote:
> Not _another_ proc entry!

Yes, not another one.  Why not move these to driverfs, where they
belong.

(ignore the driverfs name, it should be called kfs, or some such thing,
as stuff more than driver info should go there, just like these entries.)

thanks,

greg k-h
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
