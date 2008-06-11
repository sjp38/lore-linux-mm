Received: by rv-out-0708.google.com with SMTP id f25so4644302rvb.26
        for <linux-mm@kvack.org>; Wed, 11 Jun 2008 15:26:17 -0700 (PDT)
Message-ID: <57e2b00806111526t145b097dmc662bef379a1730f@mail.gmail.com>
Date: Wed, 11 Jun 2008 23:26:17 +0100
From: "Byron Bradley" <byron.bbradley@gmail.com>
Subject: Re: [patch] UWB: make UWB selectable on all archs with USB support
In-Reply-To: <484FB149.4080000@csr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080609053908.8021a635.akpm@linux-foundation.org>
	 <alpine.DEB.1.00.0806092250200.31236@gamma> <484FB149.4080000@csr.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Vrabel <david.vrabel@csr.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 11, 2008 at 12:04 PM, David Vrabel <david.vrabel@csr.com> wrote:
> Byron Bradley wrote:
>> I'm getting the error below when compiling for ARM (Marvell Orion 5x) but
>> having trouble working out exacty why. It looks like it isn't selecting
>> any of the CONFIG_UWB* options which USB_WHCI_HCD should select. Config is
>> attached.
>
> ARM (and some other architectures) don't use drivers/Kconfig.

Thanks David, I didn't realise that. No compilation problems now.

Cheers,

-- 
Byron Bradley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
