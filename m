Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id CF5CD6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 17:04:12 -0400 (EDT)
Message-ID: <51ED9E41.3070204@sr71.net>
Date: Mon, 22 Jul 2013 14:04:01 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
References: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>  <20130722083721.GC25976@gmail.com> <1374513120.16322.21.camel@misato.fc.hp.com> <51ED9CC2.8040604@gmail.com>
In-Reply-To: <51ED9CC2.8040604@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On 07/22/2013 01:57 PM, KOSAKI Motohiro wrote:
> 
> One of possible option is to return EINVAL when system has real hotplug
> device.
> I mean this interface is only useful when system don't have proper hardware
> feature and doesn't work correctly hardware property and this interface
> command
> are not consistent.
> 
> Dave, What do you think?

Sounds reasonable to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
