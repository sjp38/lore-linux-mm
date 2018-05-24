Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5AD6B0277
	for <linux-mm@kvack.org>; Thu, 24 May 2018 19:25:58 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id s7-v6so1662913ybo.4
        for <linux-mm@kvack.org>; Thu, 24 May 2018 16:25:58 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id v198-v6si5763283ywc.36.2018.05.24.16.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 24 May 2018 16:25:56 -0700 (PDT)
Date: Thu, 24 May 2018 19:25:53 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
Message-ID: <20180524232553.GI7712@thunk.org>
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
 <20180524221715.GY10363@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524221715.GY10363@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Fri, May 25, 2018 at 08:17:15AM +1000, Dave Chinner wrote:
> On Thu, May 24, 2018 at 01:43:41PM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Although the api is documented in the source code Ted has pointed out
> > that there is no mention in the core-api Documentation and there are
> > people looking there to find answers how to use a specific API.
> > 
> > Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
> > Cc: David Sterba <dsterba@suse.cz>
> > Requested-by: "Theodore Y. Ts'o" <tytso@mit.edu>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Yay, Documentation! :)

Indeed, many thanks!!!

					- Ted
