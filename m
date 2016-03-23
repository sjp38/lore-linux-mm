From: "Gioh Kim" <gurugio@hanmail.net>
Subject: RE: Re: [PATCH v2 13/18] mm/compaction: support non-lru movable
	pagemigration
Date: Thu, 24 Mar 2016 05:26:50 +0900 (KST)
Message-ID: <20160324052650.HM.e0000000006t8Yn@gurugio.wwl1662.hanmail.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6024553828274811395=="
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, YiPing Xu <xuyiping@hisilicon.com>, aquini@redhat.com, rknize@motorola.com, linux-mm@kvack.org, Chan Gyun Jeong <chan.jeong@lge.com>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, virtualization@lists.linux-foundation.org, bfields@fieldses.org, Minchan Kim <minchan@kernel.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, koct9i@gmail.com, Sangseok Lee <sangseok.lee@lge.com>, Andrew Morton <akpm@linux-foundation.org>, jlayton@poochiereds.net, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
List-Id: linux-mm.kvack.org

--===============6024553828274811395==
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: base64

PGh0bWw+PGhlYWQ+PHN0eWxlPiBwIHttYXJnaW4tdG9wOjBweDttYXJnaW4tYm90dG9tOjBw
eDt9IDwvc3R5bGU+PC9oZWFkPgo8Ym9keT48ZGl2IHN0eWxlPSJmb250LXNpemU6MTJweDsg
Zm9udC1mYW1pbHk66rW066a8LOq1tOumvOyytCxHdWxpbSxCYWVrbXVrIERvdHVtLFVuZG90
dW0sQXBwbGUgR290aGljLExhdGluIGZvbnQsc2Fucy1zZXJpZjsiPgo8dGFibGUgYm9yZGVy
PTAgd2lkdGg9MTAwJSBzdHlsZT0nbWFyZ2luIDAgYXV0bztiYWNrZ3JvdW5kOiA7JyBjZWxs
cGFkZGluZz0wIGNlbGxzcGFjaW5nPTA+Cgk8dHI+Cgk8dGQgdmFsaWduPXRvcCBzdHlsZT0n
cGFkZGluZzo4cHQ7Jz4KPGRpdiBjbGFzcz0idHgtaGFubWFpbC1jb250ZW50LXdyYXBwZXIi
IHN0eWxlPSJjb2xvcjogcmdiKDUxLCA1MSwgNTEpOyBmb250LWZhbWlseTog64+L7JuAOyBm
b250LXNpemU6IDEwcHQ7IGxpbmUtaGVpZ2h0OiAxLjU7IGJhY2tncm91bmQtY29sb3I6IHRy
YW5zcGFyZW50OyI+PGJsb2NrcXVvdGUgc3R5bGU9ImZvbnQtc2l6ZToxMnB4O2JvcmRlci1s
ZWZ0LXN0eWxlOnNvbGlkO2JvcmRlci1sZWZ0LXdpZHRoOjJweDttYXJnaW4tYm90dG9tOjBw
dDttYXJnaW4tbGVmdDowLjhleDttYXJnaW4tcmlnaHQ6MHB0O21hcmdpbi10b3A6MHB0O3Bh
ZGRpbmctbGVmdDoxZXg7Ij48ZGl2IHN0eWxlPSJmb250LWZhbWlseTphcmlhbCzrj4vsm4A7
bGluZS1oZWlnaHQ6MjBweCI+PGRpdiBjbGFzcz0idmlld21haWwtdGV4dEh0bWwiIG5hbWU9
InZpZXdtYWlsLXRleHRIdG1sIiBpZD0idmlld21haWwtdGV4dEh0bWwiPjxicj4NCkhtbW0u
Li4gQnV0LCBpbiBmYWlsdXJlIGNhc2UsIGlzIGl0IHNhZmUgdG8gY2FsbCBwdXRiYWNrX2xy
dV9wYWdlKCkgZm9yIHRoZW0/PGJyPg0KQW5kLCBQYWdlSXNvbGF0ZWQoKSB3b3VsZCBiZSBs
ZWZ0LiBJcyBpdCBva2F5PyBJdCdzIG5vdCBzeW1tZXRyaWMgdGhhdDxicj4NCmlzb2xhdGVk
IHBhZ2UgY2FuIGJlIGZyZWVkIGJ5IGRlY3JlYXNpbmcgcmVmIGNvdW50IHdpdGhvdXQgY2Fs
bGluZzxicj4NCnB1dGJhY2sgZnVuY3Rpb24uIFRoaXMgc2hvdWxkIGJlIGNsYXJpZmllZCBh
bmQgZG9jdW1lbnRlZC48YnI+DQo8YnI+PGJyPjwvZGl2PjwvZGl2PjwvYmxvY2txdW90ZT48
c3R5bGU+cCAge2ZvbnQtc2l6ZToxMHB0ICEgaW1wb3J0YW50O2ZvbnQtZmFtaWx5OuuPi+yb
gCwn6rW066a8JyxndWxpbSx0YWhvbWEsc2Fucy1zZXJpZiAhIGltcG9ydGFudDt9PC9zdHls
ZT48cD48YnI+PC9wPjxwPkkgYWdyZWUgSm9vbnNvbydzIGlkZWEuPC9wPjxwPkZyZWVpbmcg
aXNvbGF0ZWQgcGFnZSBvdXQgb2YgcHV0YmFjaygpIGNvdWxkIGJlIGNvbmZ1c2VkLjwvcD48
cD5FdmVyeSBkZXRhaWwgY2Fubm90IGJlIGRvY3VtZW50ZWQuIEFuZCBtb3JlIGRvY3VtZW50
cyBtZWFuIGxlc3MgZWxlZ2FudCBjb2RlLjwvcD48cD5JcyBpdCBwb3NzaWJsZSB0byBmcmVl
IGlzb2xhdGVkIHBhZ2UgaW4gcHV0YmFjaygpPzwvcD48cD48YnI+PC9wPjxwPkluIG1vdmVf
dG9fbmV3X3BhZ2UoKSwgY2FuIHdlIGNhbGwgYV9vcHMtJmd0O21pZ3JhdGVwYWdlIGxpa2Ug
Zm9sbG93aW5nPzwvcD48cD48YnI+PC9wPjxwPm1vdmVfdG9fbmV3X3BhZ2UoKTwvcD48cD57
PC9wPjxwPm1hcHBpbmcgPSBwYWdlX21hcHBpbmcocGFnZSk8L3A+PHA+aWYgKCFtYXBwaW5n
KTwvcD48cD4mbmJzcDsgJm5ic3A7IHJjID0gbWlncmF0ZV9wYWdlPC9wPjxwPmVsc2UgaWYg
KG1hcHBpbmctJmd0O2Ffb3BzLSZndDttaWdyYXRlcGFnZSAmYW1wOyZhbXA7IElzb2xhdGVQ
YWdlKHBhZ2UpKTwvcD48cD4mbmJzcDsgJm5ic3A7cmMgPSBtYXBwaW5nLSZndDthX29wcy0m
Z3Q7bWlncmF0ZXBhZ2U8L3A+PHA+ZWxzZTwvcD48cD4mbmJzcDsgJm5ic3A7IHJjID0gZmFs
bGJhY2tfbWlncmF0ZV9wYWdlPC9wPjxwPi4uLjwvcD48cD4mbmJzcDsgJm5ic3A7cmV0dXJu
IHJjPC9wPjxwPn08L3A+PHA+PGJyPjwvcD48cD5JJ20gc29ycnkgdGhhdCBJIGNvdWxkbid0
IHJldmlldyBpbiBkZXRhaWwgYmVjYXVzZSBJIGZvcmdvdCBtYW55IGRldGFpbHMuPC9wPjxw
Pjxicj48L3A+PC9kaXY+PC90ZD48L3RyPgo8L3RhYmxlPgo8L2Rpdj48L2JvZHk+PC9odG1s
PgoKCjwhLS0gX19IYW5tYWlsLXNpZy1TdGFydF9fIC0tPgogCQkJICA8YnI+PGJyPjxhIGhy
ZWY9Im1haWx0bzpndXJ1Z2lvQGhhbm1haWwubmV0Ij48aW1nIHNyYz0iaHR0cDovL25hbWV0
YWcuaGFubWFpbC5uZXQvS2s4TndFSDEuSS5xOTUuRmZQcy1xdzAwIiBib3JkZXI9IjAiPjwv
YT4KPCEtLSBfX0hhbm1haWwtc2lnLUVuZF9fIC0tPgoKIAo8aW1nIHNyYz0iaHR0cDovL3d3
bDE2NjIuaGFubWFpbC5uZXQ6NDI4MC9AZnJvbT1ndXJ1Z2lvJnJjcHQ9dmlydHVhbGl6YXRp
b24lNDBsaXN0cyUyRWxpbnV4JTJEZm91bmRhdGlvbiUyRW9yZyZtc2dpZD0lM0MyMDE2MDMy
NDA1MjY1MCUyRUhNJTJFZTAwMDAwMDAwMDZ0OFluJTQwZ3VydWdpbyUyRXd3bDE2NjIlMkVo
YW5tYWlsJTJFbmV0JTNFIj4K

--===============6024553828274811395==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============6024553828274811395==--
