Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 148C66B0023
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 15:26:50 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id w125-v6so3290074itf.0
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:26:50 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0096.hostedemail.com. [216.40.44.96])
        by mx.google.com with ESMTPS id r127-v6si145107itr.77.2018.03.28.12.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 12:26:48 -0700 (PDT)
Message-ID: <1522265204.12357.128.camel@perches.com>
Subject: Re: [PATCH] mm: Use octal not symbolic permissions
From: Joe Perches <joe@perches.com>
Date: Wed, 28 Mar 2018 12:26:44 -0700
In-Reply-To: <20180328190726.GR9275@dhcp22.suse.cz>
References: 
	<2e032ef111eebcd4c5952bae86763b541d373469.1522102887.git.joe@perches.com>
	 <20180328130623.GB8976@dhcp22.suse.cz>
	 <1522251891.12357.102.camel@perches.com>
	 <20180328190726.GR9275@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2018-03-28 at 21:07 +0200, Michal Hocko wrote:
> I wasn't aware that checkpatch can perform changes as well.

Someone (probably me) should write some better documentation
for checkpatch one day.

The command-line --help output isn't obvious.
