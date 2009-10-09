Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 99D0C6B004F
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 16:34:44 -0400 (EDT)
Message-ID: <4ACF9E5B.9060205@redhat.com>
Date: Fri, 09 Oct 2009 16:34:35 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] vmscan: kill shrink_all_zones()
References: <20091009174756.12B5.A69D9226@jp.fujitsu.com> <20091009175559.12B8.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091009175559.12B8.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

> At that time, their patch was pretty worth. However, Modern Hardware
> trend and recent VM improvement broke its worth. From several reason,
> I think we should remove shrink_all_zones() at all.

> Cc: Rafael J. Wysocki <rjw@sisk.pl>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
