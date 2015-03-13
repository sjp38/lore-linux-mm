Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id D4EEC829C4
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 12:04:34 -0400 (EDT)
Received: by qcwb13 with SMTP id b13so27654566qcw.12
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 09:04:34 -0700 (PDT)
Received: from pd.grulic.org.ar (pd.grulic.org.ar. [200.16.16.187])
        by mx.google.com with ESMTP id i4si2267717qcz.48.2015.03.13.09.04.33
        for <linux-mm@kvack.org>;
        Fri, 13 Mar 2015 09:04:34 -0700 (PDT)
Date: Fri, 13 Mar 2015 13:04:28 -0300
From: Marcos Dione <mdione@grulic.org.ar>
Subject: Re: committed memory, mmaps and shms
Message-ID: <20150313160427.GA23826@grulic.org.ar>
References: <20150311181044.GC14481@diablo.grulicueva.local>
 <20150312124053.GA30035@dhcp22.suse.cz>
 <20150312145422.GA9240@grulic.org.ar>
 <20150312153513.GA14537@dhcp22.suse.cz>
 <20150312165600.GC9240@grulic.org.ar>
 <20150313140958.GC4881@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150313140958.GC4881@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, marcos-david.dione@amadeus.com, linux-mm@kvack.org

On Fri, Mar 13, 2015 at 03:09:58PM +0100, Michal Hocko wrote:
> Well, the memory management subsystem is rather complex and it is not
> really trivial to match all the possible combinations into simple
> counters.

    Yes, I imagine.

> I would be interested in the particular usecase where you want the
> specific information and it is important outside of debugging purposes.

    Well, now it's more sheer curiosity than anything else, except for
the Commited_AS, which is directly related to work. I personalyy prefer
to a) have a full picture in my head and b) have it documented somwhere,
if at least in this thread. 

	-- Marcos.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
