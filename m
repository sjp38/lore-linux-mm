Date: Tue, 28 Oct 2008 19:00:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH/RESEND] include/linux/mca-legacy.h: Fix the warning of
 note
Message-Id: <20081028190059.3d59fec7.akpm@linux-foundation.org>
In-Reply-To: <20081029014918.GA9649@ubuntu>
References: <20081029014918.GA9649@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jianjun Kong <jianjun@zeuux.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Oct 2008 09:49:18 +0800 Jianjun Kong <jianjun@zeuux.org> wrote:

> include/linux/mca-legacy.h: Fix the warning of note

When preparing patch changelogs, it is usually not sufficient to just
describe the change itself.  Often that is obvious from the patch
itself, as in this case.

Instead, please take care to explain to us *why* a change was made.

> Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
> ---
>  include/linux/mca-legacy.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/mca-legacy.h b/include/linux/mca-legacy.h
> index 7a3aea8..e349f2b 100644
> --- a/include/linux/mca-legacy.h
> +++ b/include/linux/mca-legacy.h
> @@ -9,7 +9,7 @@
>  
>  #include <linux/mca.h>
>  
> -#warning "MCA legacy - please move your driver to the new sysfs api"
> +/* warning "MCA legacy - please move your driver to the new sysfs api" */
>  
>  /* MCA_NOTFOUND is an error condition.  The other two indicate
>   * motherboard POS registers contain the adapter.  They might be

Why was this change made?

As far as I can tell, the patch is wrong?  Any driver which is using
the interfaces declared by mca-legacy.h should be changed to use the
sysfs API (whatever that is - I'm not sure).

So this warning should remain in place until all such drivers have been
converted to that API.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
