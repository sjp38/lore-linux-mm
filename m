Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 881BA60021B
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 16:04:49 -0500 (EST)
Message-ID: <4B1C1C6A.8070209@redhat.com>
Date: Sun, 06 Dec 2009 16:04:42 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] high system time & lock contention running large mixed
 workload
References: <20091125133752.2683c3e4@bree.surriel.com>	 <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>	 <20091201102645.5C0A.A69D9226@jp.fujitsu.com>	 <1259685662.2345.11.camel@dhcp-100-19-198.bos.redhat.com>	 <4B15CEE0.2030503@redhat.com>	 <1259878496.2345.57.camel@dhcp-100-19-198.bos.redhat.com>	 <4B1857ED.30304@redhat.com> <1259962013.3221.8.camel@dhcp-100-19-198.bos.redhat.com>
In-Reply-To: <1259962013.3221.8.camel@dhcp-100-19-198.bos.redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On 12/04/2009 04:26 PM, Larry Woodman wrote:

>
> Here it is:

Kosaki's patch series looks a lot more complete.

Does Kosaki's patch series resolve your issue?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
