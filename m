Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4AAC16B00AB
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 04:06:07 -0500 (EST)
Date: Thu, 5 Mar 2009 10:06:18 +0100
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: drop_caches ...
Message-ID: <20090305090618.GB23266@ics.muni.cz>
References: <200903041057.34072.M4rkusXXL@web.de> <200903041447.49534.M4rkusXXL@web.de> <49AE8BA8.3080504@redhat.com> <200903041947.41542.M4rkusXXL@web.de> <20090305004850.GA6045@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20090305004850.GA6045@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Markus <M4rkusXXL@web.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zdenek Kabelac <zkabelac@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,

On Thu, Mar 05, 2009 at 08:48:50AM +0800, Wu Fengguang wrote:
> Markus, you may want to try this patch, it will have better chance to figure
> out the hidden file pages.

just for curiosity, would it be possible to print process name which caused
the file to be loaded into caches?

-- 
Luka1 Hejtmanek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
