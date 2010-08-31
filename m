Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8584F6B01F2
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 23:47:43 -0400 (EDT)
Received: by iwn33 with SMTP id 33so7572442iwn.14
        for <linux-mm@kvack.org>; Mon, 30 Aug 2010 20:47:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100831110815.87D9.A69D9226@jp.fujitsu.com>
References: <20100831102557.87D3.A69D9226@jp.fujitsu.com>
	<AANLkTinhVnMW8f7+jQdDyEzD=O2YPLSyTuGRE2JnRVzm@mail.gmail.com>
	<20100831110815.87D9.A69D9226@jp.fujitsu.com>
Date: Tue, 31 Aug 2010 12:47:41 +0900
Message-ID: <AANLkTi=FA=m_OqfY6LaX2dXfiHWoa9-70B=uKiuXYg4y@mail.gmail.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 31, 2010 at 11:09 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> How about this?
>>
>> (Not formal patch. If we agree, I will post it later when I have a SMTP)=
