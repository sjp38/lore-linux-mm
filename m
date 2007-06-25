Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id l5PHZW7M027918
	for <linux-mm@kvack.org>; Mon, 25 Jun 2007 10:35:32 -0700
Received: from ug-out-1314.google.com (ugey2.prod.google.com [10.66.176.2])
	by zps37.corp.google.com with ESMTP id l5PHZQ0S027464
	for <linux-mm@kvack.org>; Mon, 25 Jun 2007 10:35:27 -0700
Received: by ug-out-1314.google.com with SMTP id y2so1716390uge
        for <linux-mm@kvack.org>; Mon, 25 Jun 2007 10:35:26 -0700 (PDT)
Message-ID: <6599ad830706251035t37f916dcr5e35e40e3470482c@mail.gmail.com>
Date: Mon, 25 Jun 2007 10:35:26 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC] mm-controller
In-Reply-To: <467BFA47.4050802@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1182418364.21117.134.camel@twins>
	 <467A5B1F.5080204@linux.vnet.ibm.com>
	 <1182433855.21117.160.camel@twins>
	 <467BFA47.4050802@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, balbir@linux.vnet.ibm.com, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>, Pavel Emelianov <xemul@sw.ru>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>, Roy Huang <royhuang9@gmail.com>, Aubrey Li <aubreylee@gmail.com>
List-ID: <linux-mm.kvack.org>

On 6/22/07, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com> wrote:
>
> Merging both limits will eliminate the issue, however we would need
> individual limits for pagecache and RSS for better control.  There are
> use cases for pagecache_limit alone without RSS_limit like the case of
> database application using direct IO, backup applications and
> streaming applications that does not make good use of pagecache.
>

If streaming applications would otherwise litter the pagecache with
unwanted data, then limiting their total memory footprint (with a
single limit) and forcing them to drop old data sooner sounds like a
great idea.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
