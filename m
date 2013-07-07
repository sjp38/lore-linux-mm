Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 386016B0034
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:38:50 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id v20so3146132lbc.17
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:38:48 -0700 (PDT)
Message-ID: <51D98B84.4000607@kernel.org>
Date: Sun, 07 Jul 2013 18:38:44 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/5] mm/slab: Fix drain freelist excessively
References: <1372898006-6308-1-git-send-email-liwanp@linux.vnet.ibm.com> <0000013faf0d3958-00e5e945-25d8-43c1-ac6e-3d3ad69b2718-000000@email.amazonses.com> <20130707092448.GA11177@hacker.(null)>
In-Reply-To: <20130707092448.GA11177@hacker.(null)>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 7/7/13 12:24 PM, Wanpeng Li wrote:
> On Fri, Jul 05, 2013 at 01:37:28PM +0000, Christoph Lameter wrote:
>> On Thu, 4 Jul 2013, Wanpeng Li wrote:
>>
>>> This patch fix the callers that pass # of objects. Make sure they pass #
>>> of slabs.
>>
>> Acked-by: Christoph Lameter <cl@linux.com>
>
> Hi Pekka,
>
> Is it ok for you to pick this patchset? ;-)

Applied, thanks a lot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
