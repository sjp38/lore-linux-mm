Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44DD76B48AB
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 19:28:47 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 90-v6so1297658pla.18
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 16:28:47 -0700 (PDT)
Received: from sonic310-49.consmr.mail.gq1.yahoo.com (sonic310-49.consmr.mail.gq1.yahoo.com. [98.137.69.175])
        by mx.google.com with ESMTPS id h17-v6si2237756pgj.214.2018.08.28.16.28.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 16:28:46 -0700 (PDT)
From: Gao Xiang <hsiangkao@aol.com>
Subject: Re: Tagged pointers in the XArray
References: <20180828222727.GD11400@bombadil.infradead.org>
Message-ID: <5ee533e3-ea31-1fdc-7f37-5c7bd4f61e20@aol.com>
Date: Wed, 29 Aug 2018 07:24:31 +0800
MIME-Version: 1.0
In-Reply-To: <20180828222727.GD11400@bombadil.infradead.org>
Content-Type: multipart/alternative;
 boundary="------------B44D22CC79806629E4F21F58"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Gao Xiang <gaoxiang25@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Chao Yu <yuchao0@huawei.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

This is a multi-part message in MIME format.
--------------B44D22CC79806629E4F21F58
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hi,

On 2018/8/29 6:27, Matthew Wilcox wrote:
> I find myself caught between two traditions.
>
> On the one hand, the radix tree has been calling the page cache dirty &
> writeback bits "tags" for over a decade.
>
> On the other hand, using some of the bits _in a pointer_ as a tag has been
> common practice since at least the 1960s.
> https://en.wikipedia.org/wiki/Tagged_pointer and
> https://en.wikipedia.org/wiki/31-bit

Personally I think this topic makes sense. These two `tags' are totally
different actually.

> EROFS wants to use tagged pointers in the radix tree / xarray.  Right now,
> they're building them by hand, which is predictably grotty-looking.
> I think it's reasonable to provide this functionality as part of the
> XArray API, _but_ it's confusing to have two different things called tags.
>
> I've done my best to document my way around this, but if we want to rename
> the things that the radix tree called tags to avoid the problem entirely,
> now is the time to do it.  Anybody got a Good Idea?

As Matthew pointed out, it is a good chance to rename one of them.


In addition to that, I am also looking forward to a better general
tagged pointer
implementation to wrap up operations for all these tags and restrict the
number of tag bits
at compile time. It is also useful to mark its usage and clean up these
magic masks
though the implementation could look a bit simple.

If you folks think the general tagged pointer is meaningless, please
ignore my words....
However according to my EROFS coding experience, code with different
kind of tagged
pointers by hand (directly use magic masks) will be in a mess, but it
also seems
unnecessary to introduce independent operations for each kind of tagged
pointers.


In the end, I also hope someone interested in this topic and thanks in
advance... :)


Thanks,
Gao Xiang

--------------B44D22CC79806629E4F21F58
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p>Hi,</p>
    <div class="moz-cite-prefix">On 2018/8/29 6:27, Matthew Wilcox
      wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:20180828222727.GD11400@bombadil.infradead.org">
      <pre wrap="">I find myself caught between two traditions.

On the one hand, the radix tree has been calling the page cache dirty &amp;
writeback bits "tags" for over a decade.

On the other hand, using some of the bits <span class="moz-txt-underscore"><span class="moz-txt-tag">_</span>in a pointer<span class="moz-txt-tag">_</span></span> as a tag has been
common practice since at least the 1960s.
<a class="moz-txt-link-freetext" href="https://en.wikipedia.org/wiki/Tagged_pointer" moz-do-not-send="true">https://en.wikipedia.org/wiki/Tagged_pointer</a> and
<a class="moz-txt-link-freetext" href="https://en.wikipedia.org/wiki/31-bit" moz-do-not-send="true">https://en.wikipedia.org/wiki/31-bit</a></pre>
    </blockquote>
    <br>
    Personally I think <span style="color: rgb(51, 51, 51);
      font-family: arial; font-size: 18px; font-style: normal;
      font-variant-ligatures: normal; font-variant-caps: normal;
      font-weight: 400; letter-spacing: normal; orphans: 2; text-align:
      start; text-indent: 0px; text-transform: none; white-space:
      normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width:
      0px; background-color: rgb(255, 255, 255); text-decoration-style:
      initial; text-decoration-color: initial; display: inline
      !important; float: none;">this topic makes sense. These two `tags'
      are totally different actually.<br>
      <br>
    </span>
    <blockquote type="cite"
      cite="mid:20180828222727.GD11400@bombadil.infradead.org">
      <pre wrap="">
EROFS wants to use tagged pointers in the radix tree / xarray.  Right now,
they're building them by hand, which is predictably grotty-looking.
I think it's reasonable to provide this functionality as part of the
XArray API, <span class="moz-txt-underscore"><span class="moz-txt-tag">_</span>but<span class="moz-txt-tag">_</span></span> it's confusing to have two different things called tags.

I've done my best to document my way around this, but if we want to rename
the things that the radix tree called tags to avoid the problem entirely,
now is the time to do it.  Anybody got a Good Idea?</pre>
    </blockquote>
    <span style="color: rgb(51, 51, 51); font-family: arial; font-size:
      18px; font-style: normal; font-variant-ligatures: normal;
      font-variant-caps: normal; font-weight: 400; letter-spacing:
      normal; orphans: 2; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: 2;
      word-spacing: 0px; -webkit-text-stroke-width: 0px;
      background-color: rgb(255, 255, 255); text-decoration-style:
      initial; text-decoration-color: initial; display: inline
      !important; float: none;"><br>
      As Matthew pointed out, it is a good chance to rename one of them.<br>
      <br>
      <br>
      In addition to that, I am also looking forward to a better general
      tagged pointer<br>
      implementation to wrap up operations for all these tags and
      restrict the number of tag bits<br>
      at compile time. It is also useful to mark its usage and clean up
      these magic masks<br>
      though the implementation could look a bit simple.<br>
      <br>
      If you folks think the </span><span style="color: rgb(51, 51,
      51); font-family: arial; font-size: 18px; font-style: normal;
      font-variant-ligatures: normal; font-variant-caps: normal;
      font-weight: 400; letter-spacing: normal; orphans: 2; text-align:
      start; text-indent: 0px; text-transform: none; white-space:
      normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width:
      0px; background-color: rgb(255, 255, 255); text-decoration-style:
      initial; text-decoration-color: initial; display: inline
      !important; float: none;"><span style="color: rgb(51, 51, 51);
        font-family: arial; font-size: 18px; font-style: normal;
        font-variant-ligatures: normal; font-variant-caps: normal;
        font-weight: 400; letter-spacing: normal; orphans: 2;
        text-align: start; text-indent: 0px; text-transform: none;
        white-space: normal; widows: 2; word-spacing: 0px;
        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,
        255); text-decoration-style: initial; text-decoration-color:
        initial; display: inline !important; float: none;">general
        tagged pointer is meaningless, please ignore my words....<br>
        However according to my EROFS coding experience, code with
        different kind of tagged<br>
        pointers by hand (directly use </span></span><span
      style="color: rgb(51, 51, 51); font-family: arial; font-size:
      18px; font-style: normal; font-variant-ligatures: normal;
      font-variant-caps: normal; font-weight: 400; letter-spacing:
      normal; orphans: 2; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: 2;
      word-spacing: 0px; -webkit-text-stroke-width: 0px;
      background-color: rgb(255, 255, 255); text-decoration-style:
      initial; text-decoration-color: initial; display: inline
      !important; float: none;"><span style="color: rgb(51, 51, 51);
        font-family: arial; font-size: 18px; font-style: normal;
        font-variant-ligatures: normal; font-variant-caps: normal;
        font-weight: 400; letter-spacing: normal; orphans: 2;
        text-align: start; text-indent: 0px; text-transform: none;
        white-space: normal; widows: 2; word-spacing: 0px;
        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,
        255); text-decoration-style: initial; text-decoration-color:
        initial; display: inline !important; float: none;"><span
          style="color: rgb(51, 51, 51); font-family: arial; font-size:
          18px; font-style: normal; font-variant-ligatures: normal;
          font-variant-caps: normal; font-weight: 400; letter-spacing:
          normal; orphans: 2; text-align: start; text-indent: 0px;
          text-transform: none; white-space: normal; widows: 2;
          word-spacing: 0px; -webkit-text-stroke-width: 0px;
          background-color: rgb(255, 255, 255); text-decoration-style:
          initial; text-decoration-color: initial; display: inline
          !important; float: none;">magic masks) will be in a mess, but
          it also seems<br>
          unnecessary to </span></span></span><span style="color:
      rgb(51, 51, 51); font-family: arial; font-size: 18px; font-style:
      normal; font-variant-ligatures: normal; font-variant-caps: normal;
      font-weight: 400; letter-spacing: normal; orphans: 2; text-align:
      start; text-indent: 0px; text-transform: none; white-space:
      normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width:
      0px; background-color: rgb(255, 255, 255); text-decoration-style:
      initial; text-decoration-color: initial; display: inline
      !important; float: none;"><span style="color: rgb(51, 51, 51);
        font-family: arial; font-size: 18px; font-style: normal;
        font-variant-ligatures: normal; font-variant-caps: normal;
        font-weight: 400; letter-spacing: normal; orphans: 2;
        text-align: start; text-indent: 0px; text-transform: none;
        white-space: normal; widows: 2; word-spacing: 0px;
        -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,
        255); text-decoration-style: initial; text-decoration-color:
        initial; display: inline !important; float: none;"><span
          style="color: rgb(51, 51, 51); font-family: arial; font-size:
          18px; font-style: normal; font-variant-ligatures: normal;
          font-variant-caps: normal; font-weight: 400; letter-spacing:
          normal; orphans: 2; text-align: start; text-indent: 0px;
          text-transform: none; white-space: normal; widows: 2;
          word-spacing: 0px; -webkit-text-stroke-width: 0px;
          background-color: rgb(255, 255, 255); text-decoration-style:
          initial; text-decoration-color: initial; display: inline
          !important; float: none;"><span style="color: rgb(51, 51, 51);
            font-family: arial; font-size: 18px; font-style: normal;
            font-variant-ligatures: normal; font-variant-caps: normal;
            font-weight: 400; letter-spacing: normal; orphans: 2;
            text-align: start; text-indent: 0px; text-transform: none;
            white-space: normal; widows: 2; word-spacing: 0px;
            -webkit-text-stroke-width: 0px; background-color: rgb(255,
            255, 255); text-decoration-style: initial;
            text-decoration-color: initial; display: inline !important;
            float: none;"><span style="color: rgb(51, 51, 51);
              font-family: arial; font-size: 18px; font-style: normal;
              font-variant-ligatures: normal; font-variant-caps: normal;
              font-weight: 400; letter-spacing: normal; orphans: 2;
              text-align: start; text-indent: 0px; text-transform: none;
              white-space: normal; widows: 2; word-spacing: 0px;
              -webkit-text-stroke-width: 0px; background-color: rgb(255,
              255, 255); text-decoration-style: initial;
              text-decoration-color: initial; display: inline
              !important; float: none;"><span style="color: rgb(51, 51,
                51); font-family: arial; font-size: 18px; font-style:
                normal; font-variant-ligatures: normal;
                font-variant-caps: normal; font-weight: 400;
                letter-spacing: normal; orphans: 2; text-align: start;
                text-indent: 0px; text-transform: none; white-space:
                normal; widows: 2; word-spacing: 0px;
                -webkit-text-stroke-width: 0px; background-color:
                rgb(255, 255, 255); text-decoration-style: initial;
                text-decoration-color: initial; display: inline
                !important; float: none;">introduce independent
                operations for each kind of tagged pointer</span></span></span>s.<br>
          <br>
          <br>
          In the end, I also hope someone interested in this topic and
          thanks in advance... :)<br>
          <br>
          <br>
          Thanks,<br>
          Gao Xiang<br>
        </span></span></span><span class="op_sp_fanyi_read"
      style="display: inline-block; margin-left: 4px; color: rgb(51, 51,
      51); font-family: arial; font-size: 18px; font-style: normal;
      font-variant-ligatures: normal; font-variant-caps: normal;
      font-weight: 400; letter-spacing: normal; orphans: 2; text-align:
      start; text-indent: 0px; text-transform: none; white-space:
      normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width:
      0px; background-color: rgb(255, 255, 255); text-decoration-style:
      initial; text-decoration-color: initial;"></span>
  </body>
</html>

--------------B44D22CC79806629E4F21F58--
