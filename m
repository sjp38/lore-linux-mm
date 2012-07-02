Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 0C9616B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 14:39:56 -0400 (EDT)
Date: Mon, 2 Jul 2012 11:39:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2012-06-29-17-00 uploaded
Message-Id: <20120702113955.9f0d8dde.akpm@linux-foundation.org>
In-Reply-To: <4FF180D6.4090205@parallels.com>
References: <20120630000055.AF381A02DE@akpm.mtv.corp.google.com>
	<4FF180D6.4090205@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Mon, 2 Jul 2012 15:07:02 +0400
Glauber Costa <glommer@parallels.com> wrote:

> On 06/30/2012 04:00 AM, akpm@linux-foundation.org wrote:
> > * memcg-rename-config-variables.patch
> > * memcg-rename-config-variables-fix.patch
> > * memcg-rename-config-variables-fix-fix.patch
> 
> Hi Andrew,
> 
> Do you intend to fold those ?
> 

yup.  That naming scheme says "remember to fold these".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
