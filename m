Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 340F66B0055
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 11:38:02 -0500 (EST)
Message-ID: <4ED50A63.1010805@draigBrady.com>
Date: Tue, 29 Nov 2011 16:37:55 +0000
From: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/9] readahead: basic support for backwards prefetching
References: <20111129130900.628549879@intel.com> <20111129131456.925952168@intel.com> <20111129153552.GP5635@quack.suse.cz>
In-Reply-To: <20111129153552.GP5635@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Li Shaohua <shaohua.li@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 11/29/2011 03:35 PM, Jan Kara wrote:
>   Someone already mentioned this earlier and I don't think I've seen a
> response: Do you have a realistic usecase for this? I don't think I've ever
> seen an application reading file backwards...

tac, tail -n$large, ...

cheers,
Padraig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
