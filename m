Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 762F56B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 16:58:49 -0400 (EDT)
Message-ID: <4FDA5087.7090606@linux.intel.com>
Date: Thu, 14 Jun 2012 13:58:47 -0700
From: "H. Peter Anvin" <hpa@linux.intel.com>
MIME-Version: 1.0
Subject: Re: bugs in page colouring code
References: <20120613152936.363396d5@cuia.bos.redhat.com> <20120614103627.GA25940@aftab.osrc.amd.com> <4FD9DFCE.1070609@redhat.com>
In-Reply-To: <4FD9DFCE.1070609@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Borislav Petkov <bp@amd64.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sjhill@mips.com, ralf@linux-mips.org, Rob Herring <rob.herring@calxeda.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Nicolas Pitre <nico@linaro.org>

On 06/14/2012 05:57 AM, Rik van Riel wrote:
> 
> However, I expect that on x86 many applications expect
> MAP_FIXED to just work, and enforcing that would be
> more trouble than it's worth.
> 

MAP_FIXED, is well, fixed.  It means that performance be screwed, if we
can fulfill the request we MUST do so.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
