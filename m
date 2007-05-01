From: Dmitry Torokhov <dtor@insightbb.com>
Subject: Re: 2.6.22 -mm merge plans (RE: input)
Date: Mon, 30 Apr 2007 22:30:49 -0400
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704302230.50507.dtor@insightbb.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?iso-8859-1?q?=C9ric_Piel?= <Eric.Piel@tremplin-utc.net>, Jiri Slaby <jirislaby@gmail.com>
List-ID: <linux-mm.kvack.org>

On Monday 30 April 2007 19:20, Andrew Morton wrote:
> 
>  input-convert-from-class-devices-to-standard-devices.patch
>  input-evdev-implement-proper-locking.patch
>  mousedev-fix.patch
>  mousedev-fix-2.patch
> 
> Dmitry will merge these once Greg has merged the preparatory work.  Except these
> patches make the Vaio-of-doom crash in obscure circumstances, and we weren't
> able to fix that?
> 

Would like to keep cooking in your tree till we get your Vaio going,
if you don't mind.

>  wistron_btns-add-led-support.patch

Will review once again and apply.

>  input-ff-add-ff_raw-effect.patch
>  input-phantom-add-a-new-driver.patch
>

It looks like Phanotom will not be using input layer...

>  input-rfkill-add-support-for-input-key-to-control-wireless-radio.patch
> 
> Will resend to davem once the preparatory bits are merged by Greg.
>

You mean me, right? I need to do some locking changes that DaveM
pointed out.
 
-- 
Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
