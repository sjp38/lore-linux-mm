Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD49E6B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 18:11:40 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m188so103189494pgm.2
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 15:11:40 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id r18si4475970pfj.384.2017.06.29.15.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 15:11:38 -0700 (PDT)
Date: Thu, 29 Jun 2017 15:11:37 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: git send-email (w/o Cc: stable)
Message-ID: <20170629221136.xbybfjb7tyloswf3@intel.com>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170619180147.qolal6mz2wlrjbxk@pd.tnic>
 <20170621174740.npbtg2e4o65tyrss@intel.com>
 <20170622093904.ajzoi43vlkejqgi3@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170622093904.ajzoi43vlkejqgi3@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yazen Ghannam <yazen.ghannam@amd.com>

On Thu, Jun 22, 2017 at 11:39:05AM +0200, Borislav Petkov wrote:
> On Wed, Jun 21, 2017 at 10:47:40AM -0700, Luck, Tony wrote:
> > I would if I could work out how to use it. From reading the manual
> > page there seem to be a few options to this, but none of them appear
> > to just drop a specific address (apart from my own). :-(
> 
> $ git send-email --to ... --cc ... --cc ... --suppress-cc=all ...
> 
> That should send only to the ones you have in --to and --cc and suppress
> the rest.
> 
> Do a
> 
> $ git send-email -v --dry-run --to ... --cc ... --cc ... --suppress-cc=all ...
> 
> to see what it is going to do.

So there is a "--cc-cmd" option that can do the same as those "-cc" arguments.
Combine that with --suppress-cc=bodycc and things get a bit more automated.

In my .gitconfig:

[sendemail]
	suppresscc = bodycc
	ccCmd = /home/agluck/bin/sendemail.ccCmd

and the command is some sed(1) to grap the Cc: lines except the
stable@vger.kernel.org one:

sed -n \
	-e '/Cc: stable@vger.kernel.org/d' \
	-e '/^Cc: /s///p' \
	-e '/^---/q' $1

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
